---
title: "7. 데이터셋 API"
description: "전체 코퍼스 다운로드, 릴리스 관리, 증분 업데이트(diff)"
type: chapter
chapter: 7
service: datasets
base_url: https://api.semanticscholar.org/datasets/v1
topics: [datasets, releases, download, incremental-diffs, bulk-data]
endpoints:
  - method: GET
    path: /release/
    summary: 릴리스 목록 조회
  - method: GET
    path: /release/{release_id}
    summary: 릴리스 상세 조회
  - method: GET
    path: /release/{release_id}/dataset/{dataset_name}
    summary: 데이터셋 다운로드 링크
  - method: GET
    path: /diffs/{start_release_id}/to/{end_release_id}/{dataset_name}
    summary: 증분 업데이트
related: [06-recommendations.md, 08-data-models.md]
nav:
  prev: 06-recommendations.md
  next: 08-data-models.md
  index: 00-index.md
---

# 7. 데이터셋 API

Base URL: `https://api.semanticscholar.org/datasets/v1`

전체 S2AG 코퍼스를 다운로드하거나, 이전 릴리스에서 증분 업데이트를 적용할 수 있다.

## 7.1 릴리스 목록 조회

사용 가능한 데이터셋 릴리스 목록을 가져온다.

```
GET /datasets/v1/release/
```

**파라미터:** 없음

**응답:**
```json
["2023-03-14", "2023-03-21", "2023-03-28"]
```

릴리스 ID는 날짜 형식(YYYY-MM-DD)이며, 각 릴리스는 전체 데이터셋을 포함한다.

## 7.2 릴리스 상세 조회

특정 릴리스에 포함된 데이터셋 목록을 가져온다.

```
GET /datasets/v1/release/{release_id}
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `release_id` | path | string | ✅ | 릴리스 ID (날짜) 또는 `latest` |

**응답 (Release Metadata):**
```json
{
  "release_id": "2023-03-28",
  "README": "Subject to the following terms ...",
  "datasets": [
    {
      "name": "abstracts",
      "description": "Paper abstract text, where available. 100M records in 30 1.8GB files.",
      "README": "This dataset contains ..."
    }
  ]
}
```

**예시:**
```bash
curl "https://api.semanticscholar.org/datasets/v1/release/latest"
```

## 7.3 데이터셋 다운로드 링크

특정 릴리스의 특정 데이터셋 다운로드 URL을 가져온다. S3에 파티셔닝되어 저장된 파일들의 사전 서명된(pre-signed) URL 목록이 반환된다.

```
GET /datasets/v1/release/{release_id}/dataset/{dataset_name}
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `release_id` | path | string | ✅ | 릴리스 ID 또는 `latest` |
| `dataset_name` | path | string | ✅ | 데이터셋 이름 (예: `abstracts`, `papers`) |

**응답 (Dataset Metadata):**
```json
{
  "name": "abstracts",
  "description": "Paper abstract text, where available. 100M records in 30 1.8GB files.",
  "README": "Subject to terms of use as follows ...",
  "files": [
    "https://ai2-s2ag.s3.amazonaws.com/dev/staging/2023-03-28/abstracts/20230331_0..."
  ]
}
```

**다운로드 예시 (Python):**
```python
import requests, json

meta = requests.get(
    "https://api.semanticscholar.org/datasets/v1/release/latest/dataset/abstracts"
).json()

for url in meta["files"]:
    # 각 파티션 파일 다운로드
    resp = requests.get(url, stream=True)
    # ...
```

## 7.4 증분 업데이트 (Incremental Diffs)

이전 릴리스에서 최신 릴리스로의 변경분만 다운로드한다. 전체 데이터를 다시 받지 않고 기존 데이터를 업데이트할 수 있다.

```
GET /datasets/v1/diffs/{start_release_id}/to/{end_release_id}/{dataset_name}
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `start_release_id` | path | string | ✅ | 현재 보유 중인 릴리스 ID |
| `end_release_id` | path | string | ✅ | 업데이트 대상 릴리스 ID 또는 `latest` |
| `dataset_name` | path | string | ✅ | 데이터셋 이름 |

**응답 (Dataset Diff List):**
```json
{
  "dataset": "papers",
  "start_release": "2023-08-01",
  "end_release": "2023-08-29",
  "diffs": [
    {
      "from_release": "2023-08-01",
      "to_release": "2023-08-07",
      "update_files": ["https://..."],
      "delete_files": ["https://..."]
    }
  ]
}
```

각 diff는 두 개의 순차적 릴리스 간 변경분이다:
- `update_files`: 삽입 또는 갱신해야 할 레코드 (primary key 기준 upsert)
- `delete_files`: 삭제해야 할 레코드

**적용 예시 (Python — DB/KV store):**
```python
import requests, json

difflist = requests.get(
    "https://api.semanticscholar.org/datasets/v1/diffs/2023-08-01/to/latest/papers"
).json()

for diff in difflist["diffs"]:
    for url in diff["update_files"]:
        for json_line in requests.get(url).iter_lines():
            record = json.loads(json_line)
            datastore.upsert(record["corpusid"], record)
    for url in diff["delete_files"]:
        for json_line in requests.get(url).iter_lines():
            record = json.loads(json_line)
            datastore.delete(record["corpusid"])
```

**적용 예시 (PySpark):**
```python
current = sc.textFile("s3://curr-dataset").map(json.loads).keyBy(lambda x: x["corpusid"])
updates = sc.textFile("s3://diff-updates").map(json.loads).keyBy(lambda x: x["corpusid"])
deletes = sc.textFile("s3://diff-deletes").map(json.loads).keyBy(lambda x: x["corpusid"])

updated = current.fullOuterJoin(updates).mapValues(
    lambda x: x[1] if x[1] is not None else x[0]
)
updated = updated.fullOuterJoin(deletes).mapValues(
    lambda x: None if x[1] is not None else x[0]
).filter(lambda x: x[1] is not None)
updated.values().map(json.dumps).saveAsTextFile("s3://updated-dataset")
```

---
← [이전: 추천 API](06-recommendations.md) | [목차](00-index.md) | [다음: 데이터 모델 레퍼런스 →](08-data-models.md)
