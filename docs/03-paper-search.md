---
title: "3. 논문 검색 API"
description: "논문 검색 5개 엔드포인트: relevance search, bulk search, title match, autocomplete, snippet search"
---
<!-- claude:meta
type: chapter
chapter: 3
service: graph
base_url: https://api.semanticscholar.org/graph/v1
topics: [paper-search, relevance, bulk, title-match, autocomplete, snippet]
endpoints:
  - method: GET
    path: /paper/search
    summary: Paper Relevance Search
  - method: GET
    path: /paper/search/bulk
    summary: Paper Bulk Search
  - method: GET
    path: /paper/search/match
    summary: Paper Title Match
  - method: GET
    path: /paper/autocomplete
    summary: Paper Autocomplete
  - method: GET
    path: /snippet/search
    summary: Snippet Search
related: [02-common.md, 04-paper-detail.md, 08-data-models.md]
nav:
  prev: 02-common.md
  next: 04-paper-detail.md
  index: 00-index.md
-->

# 3. 논문 검색 API

## 3.1 Paper Relevance Search

논문을 관련도 순으로 검색한다. 가장 기본적인 검색 엔드포인트.

```
GET /graph/v1/paper/search
```

**파라미터:**

| 이름 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `query` | string | ✅ | 검색 쿼리 (평문) |
| `fields` | string | | 반환할 필드 목록 (쉼표 구분) |
| `offset` | integer | | 페이지네이션 시작 위치 (기본 0) |
| `limit` | integer | | 최대 반환 수 (기본 100, 최대 100) |
| `publicationDateOrYear` | string | | 출판일 범위 ([상세 형식](#publicationdateoryear) 참조) |
| `year` | string | | 출판 연도 범위 ([상세 형식](#year) 참조) |
| `venue` | string | | 학회/저널 필터 (쉼표 구분, ISO4 약칭 가능) |
| `fieldsOfStudy` | string | | 연구 분야 필터 ([전체 목록](#fieldsofstudy) 참조) |
| `publicationTypes` | string | | 출판 유형 필터 ([전체 목록](#publicationtypes) 참조) |
| `openAccessPdf` | string | | 오픈 액세스 PDF 있는 논문만 (값 없이 파라미터만 포함) |
| `minCitationCount` | string | | 최소 인용 수 (예: `200`) |

**응답 스키마:**
```json
{
  "total": 1000,
  "offset": 0,
  "next": 10,
  "data": [ { "paperId": "...", "title": "..." } ]
}
```

**제한사항:**
- 최대 1,000건의 관련도 순위 결과만 반환 가능
- 단일 응답 최대 10MB

**예시:**
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/search?query=transformer+attention&fields=title,year,citationCount&limit=5"
```

## 3.2 Paper Bulk Search

대량 논문 데이터 조회용. relevance search와 유사하나 **검색 관련도 없이** 대량 검색에 최적화되어 있다.

```
GET /graph/v1/paper/search/bulk
```

**특징:**
- 텍스트 쿼리는 필수이며 불리언 로직 지원 (빈 문자열 허용)
- 호출당 최대 **1,000건** 반환
- 더 많은 결과가 있으면 `token`이 반환됨
- 최대 **10,000,000건**까지 페이징 가능 (그 이상은 Datasets API 사용)
- 중첩 데이터(`citations`, `references` 등)는 이 엔드포인트에서 **사용 불가**

**파라미터:**

| 이름 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `query` | string | ✅ | 검색 쿼리 (제목+초록 대상, 영어 스테밍 적용, 불리언 문법 지원) |
| `token` | string | | 페이지네이션 토큰 (이전 응답에서 반환, 매 호출마다 새 토큰 발급) |
| `fields` | string | | 반환할 필드 목록 |
| `sort` | string | | 정렬 기준 (아래 상세 참조) |
| `publicationDateOrYear` | string | | 출판일 범위 |
| `year` | string | | 출판 연도 범위 |
| `venue` | string | | 학회/저널 필터 |
| `fieldsOfStudy` | string | | 연구 분야 필터 |
| `publicationTypes` | string | | 출판 유형 필터 |
| `openAccessPdf` | string | | 오픈 액세스 PDF 필터 |
| `minCitationCount` | string | | 최소 인용 수 |

**쿼리 문법 (불리언 검색):**

| 연산자 | 의미 | 예시 |
|---|---|---|
| `+` (기본) | AND | `fish ladder` → "fish" AND "ladder" |
| `\|` | OR | `fish \| ladder` → "fish" OR "ladder" |
| `-` | NOT | `fish -ladder` → "fish" but NOT "ladder" |
| `"..."` | 구문 검색 | `"fish ladder"` → 정확한 구문 |
| `*` | 접두사 매칭 | `trans*` → transformer, translation 등 |
| `(...)` | 그룹화 | `(fish ladder) \| outflow` |
| `~N` (단어 뒤) | 편집 거리 N (기본 2) | `fish~` → fish, fist, fihs 등 |
| `~N` (구문 뒤) | 단어 간 최대 N 토큰 거리 (생략 시 기본 2) | `"fish ladder"~3` → "fish is on a ladder" |

**sort 파라미터:**

형식: `field:order` (기본 `paperId:asc`)

| 정렬 필드 | 예시 | 설명 |
|---|---|---|
| `paperId` | `paperId` 또는 `paperId:asc` | ID 순 (기본값, 페이징 중 데이터 변경에 안전) |
| `publicationDate` | `publicationDate:asc` | 오래된 논문 먼저 |
| `citationCount` | `citationCount:desc` | 인용 많은 논문 먼저 |

> 정렬 값이 없는 레코드는 asc/desc 무관하게 마지막에 나타난다. 페이징 중 데이터 변경 시 기본 `paperId` 정렬이 가장 안정적이다. 동점 시 `paperId` 기준으로 정렬된다.

**응답 스키마:**
```json
{
  "total": 50000,
  "token": "NEXT_PAGE_TOKEN",
  "data": [ ... ]
}
```

**relevance search와의 차이:**

| 항목 | `/paper/search` | `/paper/search/bulk` |
|---|---|---|
| 정렬 | 관련도순 (고정) | `paperId`, `publicationDate`, `citationCount` 선택 |
| 페이지네이션 | offset/limit (최대 100) | token 기반 (최대 1,000/호출) |
| 최대 조회량 | offset 기반 제한 | 10,000,000건 |
| 중첩 데이터 | citations, references 가능 | **사용 불가** |
| 쿼리 문법 | 평문 | 불리언 연산자 지원 |
| 용도 | 사용자 대면 검색 | 대량 데이터 수집 |

## 3.3 Paper Title Match

제목과 가장 유사한 **단일 논문**을 찾는다. 이미 제목을 알고 있을 때 해당 논문의 S2 메타데이터를 가져오는 데 적합하다.

```
GET /graph/v1/paper/search/match
```

**특징:**
- **항상 단일 결과만 반환** (가장 높은 매칭 점수의 논문 1개)
- 응답에 `matchScore` 필드가 포함됨
- 매칭 실패 시 404 에러: `"Title match not found"`

**파라미터:**

| 이름 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `query` | string | ✅ | 논문 제목 (또는 유사 문자열) |
| `fields` | string | | 반환할 필드 목록 |
| `publicationDateOrYear` | string | | 출판일 범위 |
| `year` | string | | 출판 연도 범위 |
| `venue` | string | | 학회/저널 필터 |
| `fieldsOfStudy` | string | | 연구 분야 필터 |
| `publicationTypes` | string | | 출판 유형 필터 |
| `openAccessPdf` | string | | 오픈 액세스 PDF 필터 |
| `minCitationCount` | string | | 최소 인용 수 |

**예시:**
```bash
# 제목으로 논문 찾기
curl "https://api.semanticscholar.org/graph/v1/paper/search/match?query=Attention+Is+All+You+Need&fields=title,year,authors"

# 존재하지 않는 제목 → 404
curl "https://api.semanticscholar.org/graph/v1/paper/search/match?query=totalGarbageNonsense"
```

**응답 스키마:**
```json
{
  "data": [
    {
      "paperId": "...",
      "title": "...",
      "matchScore": 87.5
    }
  ]
}
```

> `data` 배열로 감싸져 있지만 항상 0~1개 결과만 포함된다. `matchScore`는 제목 매칭 신뢰도 점수다.

## 3.4 Paper Autocomplete

인터랙티브 검색 자동완성용. 부분 쿼리에 대해 최소 정보(제목 등)를 빠르게 반환한다.

```
GET /graph/v1/paper/autocomplete
```

**파라미터:**

| 이름 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `query` | string | ✅ | 부분 쿼리 문자열 (최대 100자로 잘림) |

**응답 스키마:**
```json
{
  "matches": [
    { "id": "...", "title": "...", "authorsYear": "Beltagy et al., 2019" }
  ]
}
```

## 3.5 Snippet Search

논문의 **본문 텍스트 스니펫**을 직접 검색한다. 제목/초록뿐 아니라 본문 내용까지 검색 가능하다. 약 500단어 길이의 발췌문을 반환하며, 그림 캡션과 참고문헌은 제외된다.

```
GET /graph/v1/snippet/search
```

**제한사항:**
- `query`는 필수
- `limit` 미지정 시 기본 10건 반환
- `limit` 최대 **1,000**

**파라미터:**

| 이름 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `query` | string | ✅ | 검색 쿼리 |
| `limit` | integer | | 최대 반환 수 (기본 10, 최대 1,000) |
| `fields` | string | | 스니펫 요소별 반환 필드 (아래 상세 참조) |
| `paperIds` | string | | 특정 논문으로 제한 (쉼표 구분, 최대 약 100개, 모든 ID 형식 지원) |
| `authors` | string | | 저자명 필터 (쉼표 구분, AND 로직, 퍼지 매칭, 최대 10명) |
| `minCitationCount` | string | | 최소 인용 수 |
| `insertedBefore` | string | | 인덱스 등록일 이전 필터 (`YYYY-MM-DD`, `YYYY-MM`, `YYYY`) |
| `publicationDateOrYear` | string | | 출판일 범위 |
| `year` | string | | 출판 연도 범위 |
| `venue` | string | | 학회/저널 필터 |
| `fieldsOfStudy` | string | | 연구 분야 필터 |

**`authors` 필터 상세:**
- AND 로직: `authors=galileo,kepler` → 두 저자 **모두** 포함된 논문
- 퍼지 매칭: 편집 거리 2 이내 유사 이름도 매칭 (keppler → kepler)
- OR 검색이 필요하면 각 저자별 별도 검색 수행
- 최대 10명, 초과 시 400 에러

**`fields` 파라미터 (snippet 전용):**

`paper`와 `score`는 항상 반환. `fields`로 snippet 하위 필드를 제어한다:

```
fields=snippet.text                              # 텍스트만
fields=snippet.text,snippet.snippetKind          # 텍스트 + 위치 종류
fields=snippet.annotations.sentences             # 문장 주석만
```

기본 반환 필드 (fields 미지정 시):
- `snippet.text`, `snippet.snippetKind`, `snippet.section`
- `snippet.snippetOffset` (start, end 포함)
- `snippet.annotations.refMentions` (start, end, matchedPaperCorpusId)
- `snippet.annotations.sentences` (start, end)

**응답 구조:**

각 결과에는 다음이 포함된다:

| 필드 | 설명 |
|---|---|
| `snippet.text` | 쿼리와 관련된 본문 인용문/발췌문 |
| `snippet.snippetKind` | 위치: `title`, `abstract`, `body` |
| `snippet.section` | 본문일 때 해당 섹션명 |
| `snippet.snippetOffset` | 논문 내 스니펫의 위치 정보 (`start`, `end`) |
| `snippet.annotations.refMentions` | 참조 언급 정보 (`start`, `end`, `matchedPaperCorpusId`) |
| `snippet.annotations.sentences` | 문장 경계 정보 (`start`, `end`) |
| `score` | 관련도 점수 (예: `0.562`) |
| `paper` | 해당 논문 정보 (`corpusId`, `title`, `authors`, `openAccessInfo`) |
| `retrievalVersion` | 검색 엔진 버전 정보 |

**예시:**
```bash
curl "https://api.semanticscholar.org/graph/v1/snippet/search?query=The+literature+graph+is+a+property+graph&limit=1"
```

---
← [이전: 인증 및 공통사항](02-common.md) | [목차](00-index.md) | [다음: 논문 상세 API →](04-paper-detail.md)
