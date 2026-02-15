---
title: "5. 저자 API"
description: "저자 검색, 상세 조회, 배치 조회, 저자별 논문 목록"
---
<!-- claude:meta
type: chapter
chapter: 5
service: graph
base_url: https://api.semanticscholar.org/graph/v1
topics: [author-search, author-detail, author-batch, author-papers]
endpoints:
  - method: GET
    path: /author/search
    summary: 저자 검색
  - method: GET
    path: /author/{author_id}
    summary: 저자 상세 조회
  - method: POST
    path: /author/batch
    summary: 저자 배치 조회
  - method: GET
    path: /author/{author_id}/papers
    summary: 저자별 논문 목록
related: [04-paper-detail.md, 06-recommendations.md, 08-data-models.md]
nav:
  prev: 04-paper-detail.md
  next: 06-recommendations.md
  index: 00-index.md
-->

# 5. 저자 API

## 5.1 저자 검색

이름으로 저자를 검색한다. 최대 10MB 응답 제한.

```
GET /graph/v1/author/search
```

**파라미터:**

| 이름 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `query` | string | ✅ | 저자 이름 검색 쿼리 |
| `fields` | string | | 반환할 필드 목록 |
| `offset` | integer | | 시작 위치 |
| `limit` | integer | | 최대 반환 수 (기본 100, 최대 1,000) |

> **주의**: `papers` 필드를 요청하면 각 저자에 연결된 **모든 논문**이 반환되므로, `limit`을 적절히 설정해 응답 크기와 지연시간을 관리해야 한다.

> **참고**: 검색 쿼리에 특수 문법은 지원되지 않는다. 하이픈(-)이 포함된 이름은 매칭되지 않으므로 공백으로 대체해야 한다.

**예시:**
```bash
# 기본 검색 (authorId + name, 기본 100명)
curl "https://api.semanticscholar.org/graph/v1/author/search?query=adam+smith"

# 필드 지정 + 논문 포함 + limit 축소
curl "https://api.semanticscholar.org/graph/v1/author/search?query=adam+smith&fields=name,url,papers.title,papers.year&limit=5"

# 존재하지 않는 이름 → total=0, data=[]
curl "https://api.semanticscholar.org/graph/v1/author/search?query=totalGarbageNonsense"
```

**응답 스키마:**
```json
{
  "total": 482,
  "offset": 0,
  "next": 100,
  "data": [ { "authorId": "...", "name": "..." } ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `total` | string | 대략적인 전체 결과 수 (정확하지 않을 수 있음) |
| `offset` | integer | 현재 시작 위치 |
| `next` | integer | 다음 페이지 시작 위치 (없으면 마지막 페이지) |
| `data` | array | 저자 객체 배열 |

## 5.2 저자 상세 조회

특정 저자의 상세 정보를 가져온다. 최대 10MB 응답 제한.

```
GET /graph/v1/author/{author_id}
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `author_id` | path | string | ✅ | 저자 ID |
| `fields` | query | string | | 반환할 필드 목록 |

**예시:**
```bash
# 기본 (authorId + name)
curl "https://api.semanticscholar.org/graph/v1/author/1741101"

# URL + 논문 목록 (기본 서브필드: paperId + title)
curl "https://api.semanticscholar.org/graph/v1/author/1741101?fields=url,papers"

# 논문의 초록 + 논문의 저자까지 중첩
curl "https://api.semanticscholar.org/graph/v1/author/1741101?fields=url,papers.abstract,papers.authors"
```

**반환 가능 필드** (Author 모델):

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `authorId` | string | S2 고유 저자 ID | `"1741101"` |
| `externalIds` | object | ORCID/DBLP 외부 ID | `{"DBLP": [123]}` |
| `url` | string | S2 프로필 URL | `"https://www.semanticscholar.org/author/1741101"` |
| `name` | string | 저자 이름 | `"Oren Etzioni"` |
| `affiliations` | array | 소속 기관 목록 | `["Allen Institute for AI"]` |
| `homepage` | string | 개인 홈페이지 | `"https://allenai.org/"` |
| `paperCount` | string | 총 논문 수 | `10` |
| `citationCount` | string | 총 인용 수 | `50` |
| `hIndex` | string | h-index | `5` |

> **참고**: `paperCount`, `citationCount`, `hIndex`는 Swagger 스키마상 `string` 타입이나, 실제 응답에서는 숫자 값이 반환된다.

## 5.3 저자 배치 조회

여러 저자를 한 번에 조회한다.

```
POST /graph/v1/author/batch
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `fields` | query | string | | 반환할 필드 목록 |

`authorId`는 항상 반환. 생략 시 `authorId` + `name`만 반환.

**fields 예시:**
```
fields=name,affiliations,papers          # 이름, 소속, 논문
fields=url,papers.year,papers.authors    # URL, 논문의 연도/저자
```

**요청 본문:**
```json
{
  "ids": ["1741101", "2108700"]
}
```

**제한사항:**
- 최대 **1,000개** Author ID
- 단일 응답 최대 **10MB**

## 5.4 저자의 논문 목록

특정 저자의 논문을 배치로 가져온다.

```
GET /graph/v1/author/{author_id}/papers
```

> **주의**: 배치 내 논문의 citations/references는 **최근 10,000건**만 반환. 전체 인용을 가져오려면 `/paper/{paper_id}/citations` 엔드포인트를 별도로 사용해야 한다.

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `author_id` | path | string | ✅ | 저자 ID |
| `fields` | query | string | | 반환할 필드 목록 |
| `offset` | query | integer | | 시작 위치 |
| `limit` | query | integer | | 최대 반환 수 (기본 100, 최대 1,000) |
| `publicationDateOrYear` | query | string | | 출판일 범위 필터 |

**예시:**
```bash
# 기본 (첫 100편, paperId + title)
curl "https://api.semanticscholar.org/graph/v1/author/1741101/papers"

# 필드 지정 + limit
curl "https://api.semanticscholar.org/graph/v1/author/1741101/papers?fields=url,year,authors&limit=2"

# 인용 논문의 저자까지 중첩 + offset
curl "https://api.semanticscholar.org/graph/v1/author/1741101/papers?fields=citations.authors&offset=260"
```

---
← [이전: 논문 상세 API](04-paper-detail.md) | [목차](00-index.md) | [다음: 추천 API →](06-recommendations.md)
