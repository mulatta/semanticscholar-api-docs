---
title: "부록"
description: "전체 엔드포인트 요약표 + 실전 활용 패턴 6개 (인용 그래프, 대량 수집, 공동 저자 네트워크, 추천, 증분 업데이트, 엔드포인트 선택)"
type: appendix
topics: [endpoint-summary, usage-patterns, citation-graph, bulk-collection, co-author-network, recommendations-pattern, incremental-update, endpoint-selection]
related: [00-index.md, 03-paper-search.md, 04-paper-detail.md, 05-author.md, 06-recommendations.md, 07-datasets.md]
nav:
  prev: 08-data-models.md
  next: null
  index: 00-index.md
---

# 부록 A: 전체 엔드포인트 요약

| # | 서비스 | 메서드 | 엔드포인트 | 설명 |
|---|---|---|---|---|
| 1 | Graph | GET | `/paper/search` | 논문 관련도 검색 |
| 2 | Graph | GET | `/paper/search/bulk` | 논문 대량 검색 |
| 3 | Graph | GET | `/paper/search/match` | 논문 제목 매칭 |
| 4 | Graph | GET | `/paper/autocomplete` | 논문 자동완성 |
| 5 | Graph | GET | `/snippet/search` | 본문 스니펫 검색 |
| 6 | Graph | GET | `/paper/{paper_id}` | 논문 단일 조회 |
| 7 | Graph | POST | `/paper/batch` | 논문 배치 조회 |
| 8 | Graph | GET | `/paper/{paper_id}/citations` | 인용 논문 목록 |
| 9 | Graph | GET | `/paper/{paper_id}/references` | 참조 논문 목록 |
| 10 | Graph | GET | `/paper/{paper_id}/authors` | 논문 저자 목록 |
| 11 | Graph | GET | `/author/search` | 저자 검색 |
| 12 | Graph | GET | `/author/{author_id}` | 저자 상세 조회 |
| 13 | Graph | POST | `/author/batch` | 저자 배치 조회 |
| 14 | Graph | GET | `/author/{author_id}/papers` | 저자별 논문 목록 |
| 15 | Recs | GET | `/papers/forpaper/{paper_id}` | 단일 논문 기반 추천 |
| 16 | Recs | POST | `/papers/` | 다중 논문 기반 추천 |
| 17 | Data | GET | `/release/` | 릴리스 목록 |
| 18 | Data | GET | `/release/{release_id}` | 릴리스 상세 |
| 19 | Data | GET | `/release/{release_id}/dataset/{dataset_name}` | 데이터셋 다운로드 링크 |
| 20 | Data | GET | `/diffs/{start_release_id}/to/{end_release_id}/{dataset_name}` | 증분 업데이트 diff |

---

# 부록 B: 실전 활용 패턴

## B.1 인용 그래프 탐색 (2-hop)

특정 논문을 인용한 논문들이 또 인용한 논문까지 탐색:

```python
import requests

BASE = "https://api.semanticscholar.org/graph/v1"
PAPER_ID = "649def34f8be52c8b66281af98ae884c09aef38b"

# 1-hop: 이 논문을 인용한 논문들
citations = requests.get(
    f"{BASE}/paper/{PAPER_ID}/citations",
    params={"fields": "citingPaper.paperId,citingPaper.title", "limit": 10}
).json()

# 2-hop: 인용 논문들의 참조 논문들
for c in citations["data"]:
    citing_id = c["citingPaper"]["paperId"]
    refs = requests.get(
        f"{BASE}/paper/{citing_id}/references",
        params={"fields": "citedPaper.title", "limit": 5}
    ).json()
```

## B.2 특정 분야의 고인용 논문 대량 수집

```python
import requests

BASE = "https://api.semanticscholar.org/graph/v1"
papers = []
token = None

while True:
    params = {
        "query": "large language model",
        "fields": "title,year,citationCount,authors",
        "fieldsOfStudy": "Computer Science",
        "minCitationCount": "100",
        "sort": "citationCount:desc",
    }
    if token:
        params["token"] = token

    resp = requests.get(f"{BASE}/paper/search/bulk", params=params).json()
    papers.extend(resp.get("data", []))
    token = resp.get("token")

    if not token:
        break

print(f"Total: {len(papers)} papers")
```

## B.3 저자의 공동 저자 네트워크

```python
import requests
from collections import Counter

BASE = "https://api.semanticscholar.org/graph/v1"
AUTHOR_ID = "1741101"

# 저자의 모든 논문에서 공동 저자 수집
papers = requests.get(
    f"{BASE}/author/{AUTHOR_ID}/papers",
    params={"fields": "authors", "limit": 1000}
).json()

coauthors = Counter()
for paper in papers["data"]:
    for author in paper.get("authors", []):
        if author["authorId"] != AUTHOR_ID:
            coauthors[author["name"]] += 1

# 상위 공동 저자
for name, count in coauthors.most_common(10):
    print(f"{name}: {count} papers")
```

## B.4 논문 추천: positive/negative 활용

읽은 논문 중 좋았던 것과 관심 없는 것을 구분하여 맞춤 추천:

```python
import requests

resp = requests.post(
    "https://api.semanticscholar.org/recommendations/v1/papers/",
    params={"fields": "title,year,citationCount,openAccessPdf", "limit": 20},
    json={
        "positivePaperIds": [
            "ARXIV:2005.14165",  # GPT-3
            "ARXIV:2303.08774",  # GPT-4
        ],
        "negativePaperIds": [
            "ARXIV:1810.04805",  # BERT (관심 없음)
        ]
    }
).json()

for paper in resp["recommendedPapers"]:
    pdf = paper.get("openAccessPdf", {})
    print(f"[{paper['year']}] {paper['title']} (citations: {paper['citationCount']})")
    if pdf:
        print(f"  PDF: {pdf.get('url')}")
```

## B.5 데이터셋 증분 업데이트 워크플로우

```bash
# 1. 현재 보유 릴리스 확인
curl "https://api.semanticscholar.org/datasets/v1/release/" | jq '.[-3:]'

# 2. 최신 릴리스 정보 확인
curl "https://api.semanticscholar.org/datasets/v1/release/latest" | jq '.release_id'

# 3. diff 다운로드 (보유 릴리스 → latest)
curl "https://api.semanticscholar.org/datasets/v1/diffs/2023-08-01/to/latest/papers" | jq '.diffs | length'
```

## B.6 엔드포인트 선택 가이드

| 시나리오 | 추천 엔드포인트 | 이유 |
|---|---|---|
| 사용자 검색 UI | `/paper/search` | 관련도순 정렬, offset 페이지네이션 |
| 대량 데이터 수집 | `/paper/search/bulk` | 1,000/호출, 10M건까지, 불리언 쿼리 |
| 제목으로 논문 찾기 | `/paper/search/match` | 단일 최적 매칭 결과 |
| 검색 자동완성 | `/paper/autocomplete` | 빠른 응답, 최소 데이터 |
| 본문 내용 검색 | `/snippet/search` | title/abstract/body 텍스트 발췌 |
| 특정 논문 메타데이터 | `/paper/{id}` | 전체 필드 접근 가능 |
| 수백 논문 일괄 조회 | `POST /paper/batch` | 단일 요청으로 배치 처리 |
| 인용/참조 관계 분석 | `/paper/{id}/citations` + `/references` | 문맥, 의도, 영향력 포함 |
| 유사 논문 발견 | `GET /papers/forpaper/{id}` | 간편한 단일 논문 기반 |
| 맞춤 추천 | `POST /papers/` | positive/negative 예시 활용 |
| 전체 코퍼스 분석 | Datasets API | 오프라인 대규모 분석 |

---
← [이전: 데이터 모델 레퍼런스](08-data-models.md) | [목차](00-index.md)
