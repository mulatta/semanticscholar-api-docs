---
title: "4. 논문 상세 API"
description: "논문 단일/배치 조회, 인용·참조·저자 목록 조회"
---
<!-- claude:meta
type: chapter
chapter: 4
service: graph
base_url: https://api.semanticscholar.org/graph/v1
topics: [paper-detail, paper-batch, citations, references, paper-authors]
endpoints:
  - method: GET
    path: /paper/{paper_id}
    summary: 논문 단일 조회
  - method: POST
    path: /paper/batch
    summary: 논문 배치 조회
  - method: GET
    path: /paper/{paper_id}/citations
    summary: 인용 목록
  - method: GET
    path: /paper/{paper_id}/references
    summary: 참조 목록
  - method: GET
    path: /paper/{paper_id}/authors
    summary: 저자 목록
related: [03-paper-search.md, 05-author.md, 08-data-models.md]
nav:
  prev: 03-paper-search.md
  next: 05-author.md
  index: 00-index.md
-->

# 4. 논문 상세 API

## 4.1 논문 단일 조회

특정 논문의 상세 정보를 가져온다. 최대 10MB 데이터 반환 가능.

```
GET /graph/v1/paper/{paper_id}
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `paper_id` | path | string | ✅ | 논문 ID ([2.5 논문 ID 형식](#25-논문-id-형식) 참조) |
| `fields` | query | string | | 반환할 필드 목록 |

**예시:**
```bash
# 기본 조회 (paperId + title만 반환)
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b"

# 필드 지정
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=url,year,authors"

# 인용 논문의 저자까지 중첩 요청
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=citations.authors"

# DOI로 조회
curl "https://api.semanticscholar.org/graph/v1/paper/DOI:10.18653/v1/N18-3011?fields=title,citationCount"

# ArXiv ID로 조회 + TLDR
curl "https://api.semanticscholar.org/graph/v1/paper/ARXIV:2106.15928?fields=title,tldr"

# SPECTER v2 임베딩 요청
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=title,embedding.specter_v2"
```

**반환 가능 필드** (FullPaper 모델):

`paperId`(항상 반환), `corpusId`, `externalIds`, `url`, `title`, `abstract`, `venue`, `publicationVenue`, `year`, `referenceCount`, `citationCount`, `influentialCitationCount`, `isOpenAccess`, `openAccessPdf`, `fieldsOfStudy`, `s2FieldsOfStudy`, `publicationTypes`, `publicationDate`, `journal`, `citationStyles`, `authors`, `citations`, `references`, `embedding`, `tldr`, `textAvailability`

## 4.2 논문 배치 조회

최대 500개의 논문을 한 번의 요청으로 조회한다.

```
POST /graph/v1/paper/batch
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `fields` | query | string | | 반환할 필드 목록 |

**요청 본문:**
```json
{
  "ids": [
    "649def34f8be52c8b66281af98ae884c09aef38b",
    "ARXIV:2106.15928",
    "DOI:10.18653/v1/N18-3011"
  ]
}
```

> `ids` 배열에 다양한 형식의 ID를 혼합해서 사용할 수 있다.

**예시:**
```bash
curl -X POST "https://api.semanticscholar.org/graph/v1/paper/batch?fields=title,year,citationCount" \
  -H "Content-Type: application/json" \
  -d '{"ids": ["ARXIV:2106.15928", "DOI:10.1145/3132847.3133079"]}'
```

**제한사항:**
- 최대 **500개** Paper ID
- 단일 응답 최대 **10MB**
- 논문당 최대 **9,999건**의 citations/references만 반환

## 4.3 논문의 인용 목록 (Citations)

이 논문을 인용한 논문들의 목록을 가져온다 (= 이 논문이 다른 논문의 참고문헌에 등장하는 경우).

```
GET /graph/v1/paper/{paper_id}/citations
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `paper_id` | path | string | ✅ | 논문 ID |
| `fields` | query | string | | 반환할 필드 목록 |
| `offset` | query | integer | | 시작 위치 (기본 0) |
| `limit` | query | integer | | 최대 반환 수 (기본 100, 최대 1,000) |
| `publicationDateOrYear` | query | string | | 출판일 범위 필터 |

**fields 사용법:**

`citingPaper` 하위 필드는 일반 필드처럼 직접 요청한다:

```
fields=contexts,intents,isInfluential,abstract    # citingPaper의 abstract
fields=contexts,title,authors                     # citingPaper의 title, authors
```

**예시:**
```bash
# 기본 조회 (citingPaper의 paperId + title)
curl ".../paper/649def.../citations"

# 인용 문맥 + 의도 + 초록
curl ".../paper/649def.../citations?fields=contexts,intents,isInfluential,abstract&offset=200&limit=10"

# 인용 논문의 저자 목록
curl ".../paper/649def.../citations?fields=authors&offset=1500&limit=500"
```

**응답 구조 (Citation 모델):**

| 필드 | 설명 |
|---|---|
| `citingPaper` | 인용한 논문의 상세 정보 |
| `contexts` | 인용 문맥 텍스트 배열 |
| `intents` | 인용 의도 배열 (methodology, background 등) |
| `contextsWithIntent` | 문맥+의도가 결합된 객체 배열 |
| `isInfluential` | 영향력 있는 인용 여부 |

## 4.4 논문의 참조 목록 (References)

이 논문이 참조하는 논문들의 목록을 가져온다 (= 이 논문의 참고문헌).

```
GET /graph/v1/paper/{paper_id}/references
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `paper_id` | path | string | ✅ | 논문 ID |
| `fields` | query | string | | 반환할 필드 목록 |
| `offset` | query | integer | | 시작 위치 (기본 0) |
| `limit` | query | integer | | 최대 반환 수 (기본 100, 최대 1,000) |

**응답 구조 (Reference 모델):**

| 필드 | 설명 |
|---|---|
| `citedPaper` | 참조된 논문의 상세 정보 |
| `contexts` | 참조 문맥 텍스트 배열 |
| `intents` | 인용 의도 배열 |
| `contextsWithIntent` | 문맥+의도 결합 객체 배열 |
| `isInfluential` | 영향력 있는 인용 여부 |

**Citations vs References:**

| 항목 | Citations | References |
|---|---|---|
| 방향 | 이 논문을 **인용한** 논문들 | 이 논문이 **참조한** 논문들 |
| 비유 | "누가 나를 인용했나" | "내가 누구를 인용했나" |
| 반환 객체 키 | `citingPaper` | `citedPaper` |
| `publicationDateOrYear` 필터 | ✅ 지원 | ❌ 미지원 |

## 4.5 논문의 저자 목록

특정 논문의 저자 목록을 가져온다.

```
GET /graph/v1/paper/{paper_id}/authors
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 설명 |
|---|---|---|---|---|
| `paper_id` | path | string | ✅ | 논문 ID |
| `fields` | query | string | | 반환할 필드 목록 |
| `offset` | query | integer | | 시작 위치 (기본 0) |
| `limit` | query | integer | | 최대 반환 수 (기본 100, 최대 1,000) |

**fields 사용법:**

`papers` 서브필드를 `.`으로 지정:

```
fields=name,affiliations,papers                # 저자명 + 소속 + 논문 목록
fields=url,papers.year,papers.authors          # 저자 URL + 논문의 연도/저자
```

**예시:**
```bash
# 기본 (authorId + name)
curl ".../paper/649def.../authors"

# 소속 + 논문 목록 (limit 2)
curl ".../paper/649def.../authors?fields=affiliations,papers&limit=2"

# 저자의 논문 연도 + 논문의 저자들 (offset 사용)
curl ".../paper/649def.../authors?fields=url,papers.year,papers.authors&offset=2"
```

