---
title: "8. 데이터 모델 레퍼런스"
description: "전체 데이터 모델 필드 사전 — BasePaper, FullPaper, Author, Citation, Reference, Snippet, 응답 래퍼, 특수 변형 모델"
type: chapter
chapter: 8
topics: [data-models, basepaper, fullpaper, author, citation, reference, embedding, tldr, snippet, open-access, publication-venue, fields-of-study, response-wrappers, special-models]
models:
  - BasePaper
  - FullPaper
  - Author
  - AuthorWithPapers
  - Citation
  - Reference
  - Embedding
  - TLDR
  - Snippet
  - OpenAccessPdf
  - openAccessInfo
  - PublicationVenue
  - CitationBatch
  - ReferenceBatch
  - AuthorBatch
  - AuthorPaperBatch
  - PaperRelevanceSearchBatch
  - AuthorSearchBatch
  - PaperBulkSearchBatch
  - PaperMatch
  - SnippetMatch
  - TitleMatchPaper
  - AutocompletePaper
  - PaperInfo
  - AuthorInfo
  - PaperBatch
  - AuthorIdList
related: [03-paper-search.md, 04-paper-detail.md, 05-author.md, 06-recommendations.md]
nav:
  prev: 07-datasets.md
  next: 09-appendix.md
  index: 00-index.md
---

# 8. 데이터 모델 레퍼런스

## 8.1 Paper (BasePaper)

논문 검색, 추천 등에서 반환되는 기본 논문 모델.

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `paperId` | string | S2 기본 고유 ID | `"5c5751d45e298cea054f32b392c12c61027d2fe7"` |
| `corpusId` | integer | S2 보조 고유 ID (데이터셋용) | `215416146` |
| `externalIds` | object | 외부 ID (ArXiv, MAG, ACL, PubMed, Medline, PubMedCentral, DBLP, DOI) | `{"DOI": "10.18653/V1/2020.ACL-MAIN.447", "ArXiv": "..."}` |
| `url` | string | S2 웹사이트 URL | `"https://www.semanticscholar.org/paper/5c575..."` |
| `title` | string | 논문 제목 | `"Construction of the Literature Graph in Semantic Scholar"` |
| `abstract` | string | 초록 (법적 이유로 누락될 수 있음) | `"We describe a deployed scalable system..."` |
| `venue` | string | 출판 학회/저널명 | `"Annual Meeting of the Association for Computational Linguistics"` |
| `publicationVenue` | object | 학회/저널 상세 (`id`, `name`, `type`, `alternate_names`, `url`) | `{"type": "conference", "name": "ACL"}` |
| `year` | integer | 출판 연도 | `1997` |
| `referenceCount` | integer | 참조 논문 수 | `59` |
| `citationCount` | integer | 인용 수 | `453` |
| `influentialCitationCount` | integer | 영향력 있는 인용 수 (S2 알고리즘 기반) | `90` |
| `isOpenAccess` | boolean | 오픈 액세스 여부 | `true` |
| `openAccessPdf` | object | 오픈 액세스 PDF 정보 (`url`, `status`, `license`, `disclaimer`) | `{"url": "https://...pdf", "status": "HYBRID"}` |
| `fieldsOfStudy` | array[string] | 연구 분야 (외부 소스) | `["Computer Science"]` |
| `s2FieldsOfStudy` | array[object] | S2 분류 연구 분야 (`category`, `source`) | `[{"category": "Computer Science", "source": "s2-fos-model"}]` |
| `publicationTypes` | array[string] | 출판 유형 | `["Journal Article", "Review"]` |
| `publicationDate` | string | 출판일 (YYYY-MM-DD) | `"2024-04-29"` |
| `journal` | object | 저널 정보 (`name`, `volume`, `pages`) | `{"name": "IETE Technical Review", "volume": "40"}` |
| `citationStyles` | object | BibTeX 인용 정보 | `{"bibtex": "@JournalArticle{...}"}` |
| `authors` | array[AuthorInfo] | 저자 목록 (`authorId`, `name`) | `[{"authorId": "1741101", "name": "Oren Etzioni"}]` |

## 8.2 FullPaper (단일 논문 조회 전용 추가 필드)

BasePaper의 모든 필드 + 아래 추가 필드:

| 필드 | 타입 | 설명 |
|---|---|---|
| `embedding` | object | 논문 임베딩 벡터 (`model`, `vector`) |
| `tldr` | object | AI 생성 요약 (`model`, `text`) |
| `citations` | array | 이 논문을 인용한 논문 목록 |
| `references` | array | 이 논문이 참조한 논문 목록 |
| `textAvailability` | string | 텍스트 가용성: `fulltext`, `abstract`, `none` |

## 8.3 Author

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `authorId` | string | S2 고유 저자 ID | `"1741101"` |
| `externalIds` | object | ORCID/DBLP 외부 ID | `{"DBLP": [123]}` |
| `url` | string | S2 프로필 URL | `"https://www.semanticscholar.org/author/1741101"` |
| `name` | string | 이름 | `"Oren Etzioni"` |
| `affiliations` | array[string] | 소속 기관 | `["Allen Institute for AI"]` |
| `homepage` | string | 개인 홈페이지 | `"https://allenai.org/"` |
| `paperCount` | string | 총 논문 수 | `10` |
| `citationCount` | string | 총 인용 수 | `50` |
| `hIndex` | string | h-index | `5` |

## 8.4 AuthorWithPapers

Author의 모든 필드 + `papers` (해당 저자의 논문 배열).

## 8.5 Citation

| 필드 | 타입 | 설명 |
|---|---|---|
| `citingPaper` | BasePaper | 인용한 논문의 상세 정보 |
| `contexts` | array[string] | 인용 문맥 텍스트 스니펫 배열 |
| `intents` | array[string] | 인용 의도 (methodology, background 등) |
| `contextsWithIntent` | array[object] | 문맥+의도 결합 객체 |
| `isInfluential` | boolean | 영향력 있는 인용 여부 |

## 8.6 Reference

| 필드 | 타입 | 설명 |
|---|---|---|
| `citedPaper` | BasePaper | 참조된 논문의 상세 정보 |
| `contexts` | array[string] | 참조 문맥 텍스트 스니펫 배열 |
| `intents` | array[string] | 인용 의도 |
| `contextsWithIntent` | array[object] | 문맥+의도 결합 객체 |
| `isInfluential` | boolean | 영향력 있는 인용 여부 |

## 8.7 Embedding

| 필드 | 타입 | 설명 |
|---|---|---|
| `model` | string | 임베딩 모델명 |
| `vector` | object | 임베딩 벡터 (실제 응답은 숫자 배열) |

## 8.8 TLDR

| 필드 | 타입 | 설명 |
|---|---|---|
| `model` | string | 요약 모델명 |
| `text` | string | AI 생성 한 줄 요약 |

## 8.9 Snippet

| 필드 | 타입 | 설명 |
|---|---|---|
| `text` | string | 쿼리 관련 논문 본문 발췌문 |
| `snippetKind` | string | 위치: `title`, `abstract`, `body` |
| `section` | string | 본문일 때 해당 섹션명 |
| `snippetOffset` | object | 논문 내 스니펫 위치 정보 |
| `annotations` | object | 주석 정보: `sentences` (문장 경계 start/end 배열), `refMentions` (참조 언급 start/end/matchedPaperCorpusId 배열) |

## 8.10 Open Access PDF

| 필드 | 타입 | 설명 |
|---|---|---|
| `url` | string | PDF 다운로드 링크 |
| `status` | string | OA 유형 (HYBRID, GOLD, GREEN 등) |
| `license` | string | 라이선스 (CCBY 등) |
| `disclaimer` | string | 법적 고지사항 |

> **`openAccessInfo` vs `openAccessPdf`:** Snippet Search(`/snippet/search`) 응답의 `paper` 객체에는 `openAccessPdf` 대신 `openAccessInfo`가 사용된다. `openAccessInfo`에는 `url` 필드가 **없으며** `license`, `status`, `disclaimer`만 포함된다. PDF URL이 필요하면 해당 논문을 `/paper/{paper_id}` 엔드포인트로 별도 조회해야 한다.

## 8.11 Publication Venue

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 학회/저널 고유 ID |
| `name` | string | 학회/저널 이름 |
| `type` | string | 유형 (`conference`, `journal` 등) |
| `alternate_names` | array[string] | 대체 이름/약칭 |
| `url` | string | 학회/저널 웹사이트 |

## 8.12 연구 분야 (Fields of Study)

**`fieldsOfStudy` vs `s2FieldsOfStudy` 차이:**

| 항목 | `fieldsOfStudy` | `s2FieldsOfStudy` |
|---|---|---|
| 타입 | `array[string]` | `array[object]` |
| 소스 | 외부 소스에서 할당 | 외부 + S2 자체 분류 모델 |
| 구조 | `["Computer Science"]` | `[{"category": "CS", "source": "s2-fos-model"}]` |
| `source` 값 | — | `"external"` 또는 `"s2-fos-model"` |
| 용도 | 단순 분야 확인 | 분류 출처까지 구분 필요 시 |

`s2FieldsOfStudy`는 S2가 자체 훈련한 분류 모델(s2-fos-model)의 결과를 포함하므로 외부 소스가 없는 논문도 분야 분류가 가능하다.

**사용 가능한 분야 값 (23개):**

Computer Science, Medicine, Chemistry, Biology, Materials Science, Physics, Geology, Psychology, Art, History, Geography, Sociology, Business, Political Science, Economics, Philosophy, Mathematics, Engineering, Environmental Science, Agricultural and Food Sciences, Education, Law, Linguistics

## 8.13 응답 래퍼 모델 (Response Wrappers)

각 엔드포인트는 결과를 래퍼 모델로 감싸서 반환한다. 페이지네이션 패턴에 따라 4가지 유형이 있다:

**패턴 A — offset 페이지네이션:**

| 필드 | 타입 | 설명 |
|---|---|---|
| `offset` | integer | 현재 배치 시작 위치 |
| `next` | integer | 다음 배치 시작 위치 (마지막 페이지면 없음) |
| `data` | array | 결과 배열 |

사용 모델: `CitationBatch`, `ReferenceBatch`, `AuthorBatch`, `AuthorPaperBatch`

**패턴 B — offset + total:**

| 필드 | 타입 | 설명 |
|---|---|---|
| `total` | string | 대략적인 전체 결과 수 (정확하지 않을 수 있음) |
| `offset` | integer | 현재 배치 시작 위치 |
| `next` | integer | 다음 배치 시작 위치 (마지막 페이지면 없음) |
| `data` | array | 결과 배열 |

사용 모델: `PaperRelevanceSearchBatch`, `AuthorSearchBatch`

**패턴 C — token 기반:**

| 필드 | 타입 | 설명 |
|---|---|---|
| `total` | integer | 대략적인 전체 결과 수 |
| `token` | string | 다음 페이지를 위한 continuation token |
| `data` | array | 결과 배열 |

사용 모델: `PaperBulkSearchBatch`

**패턴 D — 단순 래퍼 (페이지네이션 없음):**

| 필드 | 타입 | 설명 |
|---|---|---|
| `data` | array | 결과 배열 |

사용 모델: `PaperMatch`

**엔드포인트별 래퍼 모델 매핑:**

| 엔드포인트 | 래퍼 모델 | 패턴 |
|---|---|---|
| `GET /paper/search` | `PaperRelevanceSearchBatch` | B |
| `GET /paper/search/bulk` | `PaperBulkSearchBatch` | C |
| `GET /paper/search/match` | `PaperMatch` | D |
| `GET /paper/autocomplete` | `PaperAutocomplete` | 별도 (`matches` 배열) |
| `GET /snippet/search` | `SnippetMatch` | 별도 (`data` + `retrievalVersion`) |
| `GET /paper/{id}/citations` | `CitationBatch` | A |
| `GET /paper/{id}/references` | `ReferenceBatch` | A |
| `GET /paper/{id}/authors` | `AuthorBatch` | A |
| `GET /author/search` | `AuthorSearchBatch` | B |
| `GET /author/{id}/papers` | `AuthorPaperBatch` | A |

## 8.14 특수 변형 모델

일부 엔드포인트는 `BasePaper`/`FullPaper`와 다른 전용 모델을 반환한다:

**Title Match Paper** (`/paper/search/match` 응답):

`PaperWithLinks`의 모든 필드에 추가로:

| 필드 | 타입 | 설명 |
|---|---|---|
| `matchScore` | number | 제목 매칭 신뢰도 점수 |

> `PaperWithLinks`와 차이점: `citations`/`references`가 `PaperInfo` 대신 `BasePaper`를 참조한다.

**Autocomplete Paper** (`/paper/autocomplete` 응답):

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 논문 ID |
| `title` | string | 논문 제목 |
| `authorsYear` | string | 저자 요약 + 연도 (예: `"Beltagy et al., 2019"`) |

> 일반 Paper 모델과 달리 매우 경량화된 구조. 자동완성 UI에 최적화.

**PaperInfo** (내부 참조 모델):

| 필드 | 타입 | 설명 |
|---|---|---|
| `paperId` | string | S2 논문 ID |
| `corpusId` | integer | S2 corpus ID |
| `url` | string | S2 웹사이트 URL |
| `title` | string | 논문 제목 |
| `venue` | string | 학회/저널명 |
| `publicationVenue` | object | 학회/저널 상세 |
| `year` | integer | 출판 연도 |
| `authors` | array[AuthorInfo] | 저자 목록 |

> `PaperWithLinks`의 `citations`/`references` 내부 항목으로 사용된다. `BasePaper`의 서브셋.

**AuthorInfo** (저자 요약 모델):

| 필드 | 타입 | 설명 |
|---|---|---|
| `authorId` | string | S2 저자 ID |
| `name` | string | 저자 이름 |

> `BasePaper`/`FullPaper`의 `authors` 배열 내 각 항목의 타입. `Author`(8.3)의 축약 버전.

**요청 본문 모델:**

| 모델 | 용도 | 필드 |
|---|---|---|
| `PaperBatch` | `POST /paper/batch` 요청 본문 | `ids`: 논문 ID 문자열 배열 (최대 500개) |
| `AuthorIdList` | `POST /author/batch` 요청 본문 | `ids`: 저자 ID 문자열 배열 (최대 1,000개) |

---
← [이전: 데이터셋 API](07-datasets.md) | [목차](00-index.md) | [다음: 부록 →](09-appendix.md)
