---
title: "2. 인증 및 공통사항"
description: "API 키, Base URL, fields 파라미터, 페이지네이션, ID 형식, 필터, 에러 코드"
type: chapter
chapter: 2
topics: [authentication, api-key, fields-parameter, pagination, paper-id-formats, filters, error-codes, rate-limit]
endpoints: []
related: [01-overview.md, 03-paper-search.md]
nav:
  prev: 01-overview.md
  next: 03-paper-search.md
  index: 00-index.md
---

# 2. 인증 및 공통사항

## 2.1 API 키

API 키 없이도 사용 가능하나, rate limit이 적용된다. API 키를 사용하면 더 높은 처리량을 확보할 수 있다.

```
x-api-key: YOUR_API_KEY
```

> **주의**: 헤더 이름 `x-api-key`는 **대소문자를 구분**한다.

## 2.2 공통 요청 형식

- Content-Type: `application/json`
- Accept: `application/json`
- 모든 특수문자는 URL 인코딩 필수

## 2.3 `fields` 파라미터

거의 모든 엔드포인트에 공통으로 사용되는 핵심 파라미터다. 쉼표로 구분된 필드 목록을 지정해 응답 크기를 제어한다.

```
?fields=title,authors,year,citationCount
```

**기본 동작:**
- `fields` 생략 시 → 논문: `paperId` + `title`, 저자: `authorId` + `name`만 반환
- `fields`는 **단일 값 문자열** 파라미터 (multi-value가 아님)

**중첩 필드(서브필드) 지정:**

마침표(`.`)를 사용해 하위 필드를 지정한다:

| 상위 필드 | 기본 반환 서브필드 | 추가 서브필드 예시 |
|---|---|---|
| `authors` | `authorId`, `name` | `author.url`, `author.paperCount`, `author.hIndex` |
| `citations` | `paperId`, `title` | `citations.abstract`, `citations.authors`, `citations.year` |
| `references` | `paperId`, `title` | `references.abstract`, `references.authors` |
| `embedding` | SPECTER v1 (기본) | `embedding.specter_v2` (v2 임베딩 선택) |

**예시:**
```
fields=title,url                                    # 기본 필드만
fields=title,embedding.specter_v2                   # SPECTER v2 임베딩
fields=title,authors,citations.title,citations.abstract  # 저자 + 인용논문 제목/초록
fields=url,papers.year,papers.authors               # 저자 API에서 논문 서브필드
```

> **주의**: `/snippet/search`의 fields는 `snippet.text`, `snippet.snippetKind` 형태로 지정. `paper`와 `score`는 항상 반환되므로 지정 불가.

## 2.4 페이지네이션

두 가지 방식이 존재한다:

| 방식 | 파라미터 | 사용 엔드포인트 |
|---|---|---|
| **offset 기반** | `offset`, `limit` | `/paper/search`, `/author/search`, citations, references, authors |
| **token(cursor) 기반** | `token` | `/paper/search/bulk` |

**offset 기반 예시:**
```
GET /paper/search?query=LLM&offset=0&limit=10
GET /paper/search?query=LLM&offset=10&limit=10
```

**token 기반 예시:**
```
GET /paper/search/bulk?query=LLM
→ 응답에 "token": "abc123" 포함
GET /paper/search/bulk?query=LLM&token=abc123
```

## 2.5 논문 ID 형식

논문을 지정할 때 다양한 외부 ID를 사용할 수 있다:

| 형식 | 예시 |
|---|---|
| S2 Paper ID (SHA) | `649def34f8be52c8b66281af98ae884c09aef38b` |
| Corpus ID | `CorpusId:215416146` |
| DOI | `DOI:10.18653/v1/N18-3011` |
| ArXiv | `ARXIV:2106.15928` |
| MAG | `MAG:112218234` |
| ACL | `ACL:W12-3903` |
| PubMed | `PMID:19872477` |
| PubMed Central | `PMCID:2323736` |
| URL | `URL:https://arxiv.org/abs/2106.15928v1` |

지원 URL 사이트: semanticscholar.org, arxiv.org, aclweb.org, acm.org, biorxiv.org

## 2.6 공통 필터 파라미터 상세

검색 관련 엔드포인트(`/paper/search`, `/paper/search/bulk`, `/paper/search/match`, `/snippet/search`)에서 공통으로 사용되는 필터:

### `publicationDateOrYear`

날짜 범위 형식: `<시작>:<끝>` (각각 `YYYY-MM-DD` 형식, 양쪽 모두 선택적)

| 예시 | 의미 |
|---|---|
| `2019-03-05` | 2019년 3월 5일 당일 |
| `2019-03` | 2019년 3월 전체 |
| `2019` | 2019년 전체 |
| `2016-03-05:2020-06-06` | 2016.03.05 ~ 2020.06.06 |
| `1981-08-25:` | 1981.08.25 이후 |
| `:2015-01` | 2015년 1월 말까지 |
| `2015:2020` | 2015.01.01 ~ 2020.12.31 |

> 정확한 출판일을 모르는 논문은 해당 연도의 1월 1일로 처리된다. `publicationDate`가 null이어도 `year`는 항상 존재한다.

### `year`

연도 단위 간편 필터:

| 예시 | 의미 |
|---|---|
| `2019` | 2019년 |
| `2016-2020` | 2016~2020년 |
| `2010-` | 2010년 이후 |
| `-2015` | 2015년 이전 |

### `publicationTypes`

출판 유형 필터 (쉼표 구분, OR 로직):

| 값 | 설명 |
|---|---|
| `Review` | 리뷰 논문 |
| `JournalArticle` | 저널 논문 |
| `CaseReport` | 사례 보고 |
| `ClinicalTrial` | 임상 시험 |
| `Conference` | 학회 논문 |
| `Dataset` | 데이터셋 |
| `Editorial` | 에디토리얼 |
| `LettersAndComments` | 레터/코멘트 |
| `MetaAnalysis` | 메타분석 |
| `News` | 뉴스 |
| `Study` | 연구 |
| `Book` | 도서 |
| `BookSection` | 도서 섹션 |

예시: `publicationTypes=Review,JournalArticle` → Review **또는** JournalArticle인 논문

### `fieldsOfStudy`

연구 분야 필터 (쉼표 구분, OR 로직):

Computer Science, Medicine, Chemistry, Biology, Materials Science, Physics, Geology, Psychology, Art, History, Geography, Sociology, Business, Political Science, Economics, Philosophy, Mathematics, Engineering, Environmental Science, Agricultural and Food Sciences, Education, Law, Linguistics

예시: `fieldsOfStudy=Physics,Mathematics` → Physics **또는** Mathematics 분야 논문

### `venue`

학회/저널 필터 (쉼표 구분). 정식 명칭과 ISO4 약칭 모두 사용 가능:

예시: `venue=Nature,Radiology` 또는 `venue=N. Engl. J. Med.`

### `openAccessPdf`

오픈 액세스 PDF가 있는 논문만 필터. **값 없이 파라미터만 포함**한다:

```
?query=LLM&openAccessPdf
```

### `minCitationCount`

최소 인용 수 필터:

```
?query=LLM&minCitationCount=200
```

## 2.7 응답 크기 제한

- 모든 엔드포인트의 단일 응답 최대 크기: **10MB**
- 초과 시 400 에러: `"Response would exceed maximum size..."`
- 해결 방법: `limit` 줄이기, `fields` 최소화, 배치 분할

## 2.8 에러 응답

| 코드 | 의미 | error 필드 예시 |
|---|---|---|
| **400** | 잘못된 요청 | `"Unrecognized or unsupported fields: [bad1, bad2]"` |
| **400** | 잘못된 파라미터 | `"Unacceptable query params: [badK1=badV1]"` |
| **400** | 응답 초과 | `"Response would exceed maximum size..."` (10MB 초과 시) |
| **404** | 찾을 수 없음 | `"Paper with id ### not found"` |
| **404** | 제목 매칭 실패 | `"Title match not found"` (`/paper/search/match` 전용) |

---
← [이전: 개요](01-overview.md) | [목차](00-index.md) | [다음: 논문 검색 API →](03-paper-search.md)
