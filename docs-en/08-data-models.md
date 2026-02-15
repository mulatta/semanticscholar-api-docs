---
title: "8. Data Model Reference"
description: "Full data model field dictionary — BasePaper, FullPaper, Author, Citation, Reference, Snippet, response wrappers, special variant models"
---

# 8. Data Model Reference

## 8.1 Paper (BasePaper)

The base paper model returned by search, recommendations, etc.

| Field | Type | Description | Example |
|---|---|---|---|
| `paperId` | string | S2 primary unique ID | `"5c5751d45e298cea054f32b392c12c61027d2fe7"` |
| `corpusId` | integer | S2 secondary unique ID (for datasets) | `215416146` |
| `externalIds` | object | External IDs (ArXiv, MAG, ACL, PubMed, Medline, PubMedCentral, DBLP, DOI) | `{"DOI": "10.18653/V1/2020.ACL-MAIN.447", "ArXiv": "..."}` |
| `url` | string | S2 website URL | `"https://www.semanticscholar.org/paper/5c575..."` |
| `title` | string | Paper title | `"Construction of the Literature Graph in Semantic Scholar"` |
| `abstract` | string | Abstract (may be missing for legal reasons) | `"We describe a deployed scalable system..."` |
| `venue` | string | Publication venue name | `"Annual Meeting of the Association for Computational Linguistics"` |
| `publicationVenue` | object | Venue details (`id`, `name`, `type`, `alternate_names`, `url`) | `{"type": "conference", "name": "ACL"}` |
| `year` | integer | Publication year | `1997` |
| `referenceCount` | integer | Number of references | `59` |
| `citationCount` | integer | Citation count | `453` |
| `influentialCitationCount` | integer | Influential citation count (S2 algorithm) | `90` |
| `isOpenAccess` | boolean | Open access status | `true` |
| `openAccessPdf` | object | Open access PDF info (`url`, `status`, `license`, `disclaimer`) | `{"url": "https://...pdf", "status": "HYBRID"}` |
| `fieldsOfStudy` | array[string] | Fields of study (external source) | `["Computer Science"]` |
| `s2FieldsOfStudy` | array[object] | S2-classified fields of study (`category`, `source`) | `[{"category": "Computer Science", "source": "s2-fos-model"}]` |
| `publicationTypes` | array[string] | Publication types | `["Journal Article", "Review"]` |
| `publicationDate` | string | Publication date (YYYY-MM-DD) | `"2024-04-29"` |
| `journal` | object | Journal info (`name`, `volume`, `pages`) | `{"name": "IETE Technical Review", "volume": "40"}` |
| `citationStyles` | object | BibTeX citation info | `{"bibtex": "@JournalArticle{...}"}` |
| `authors` | array[AuthorInfo] | Author list (`authorId`, `name`) | `[{"authorId": "1741101", "name": "Oren Etzioni"}]` |

## 8.2 FullPaper (Additional Fields for Single Paper Lookup)

All BasePaper fields plus:

| Field | Type | Description |
|---|---|---|
| `embedding` | object | Paper embedding vector (`model`, `vector`) |
| `tldr` | object | AI-generated summary (`model`, `text`) |
| `citations` | array | List of papers citing this paper |
| `references` | array | List of papers referenced by this paper |
| `textAvailability` | string | Text availability: `fulltext`, `abstract`, `none` |

## 8.3 Author

| Field | Type | Description | Example |
|---|---|---|---|
| `authorId` | string | S2 unique author ID | `"1741101"` |
| `externalIds` | object | ORCID/DBLP external IDs | `{"DBLP": [123]}` |
| `url` | string | S2 profile URL | `"https://www.semanticscholar.org/author/1741101"` |
| `name` | string | Name | `"Oren Etzioni"` |
| `affiliations` | array[string] | Affiliated institutions | `["Allen Institute for AI"]` |
| `homepage` | string | Personal homepage | `"https://allenai.org/"` |
| `paperCount` | string | Total paper count | `10` |
| `citationCount` | string | Total citation count | `50` |
| `hIndex` | string | h-index | `5` |

## 8.4 AuthorWithPapers

All Author fields plus `papers` (array of the author's papers).

## 8.5 Citation

| Field | Type | Description |
|---|---|---|
| `citingPaper` | BasePaper | Details of the citing paper |
| `contexts` | array[string] | Array of citation context text snippets |
| `intents` | array[string] | Citation intents (methodology, background, etc.) |
| `contextsWithIntent` | array[object] | Combined context+intent objects |
| `isInfluential` | boolean | Whether the citation is influential |

## 8.6 Reference

| Field | Type | Description |
|---|---|---|
| `citedPaper` | BasePaper | Details of the referenced paper |
| `contexts` | array[string] | Array of reference context text snippets |
| `intents` | array[string] | Citation intents |
| `contextsWithIntent` | array[object] | Combined context+intent objects |
| `isInfluential` | boolean | Whether the citation is influential |

## 8.7 Embedding

| Field | Type | Description |
|---|---|---|
| `model` | string | Embedding model name |
| `vector` | object | Embedding vector (actual response is a numeric array) |

## 8.8 TLDR

| Field | Type | Description |
|---|---|---|
| `model` | string | Summary model name |
| `text` | string | AI-generated one-line summary |

## 8.9 Snippet

| Field | Type | Description |
|---|---|---|
| `text` | string | Query-related body text excerpt |
| `snippetKind` | string | Location: `title`, `abstract`, `body` |
| `section` | string | Section name when from body |
| `snippetOffset` | object | Position info within the paper |
| `annotations` | object | Annotation info: `sentences` (sentence boundary start/end array), `refMentions` (reference mention start/end/matchedPaperCorpusId array) |

## 8.10 Open Access PDF

| Field | Type | Description |
|---|---|---|
| `url` | string | PDF download link |
| `status` | string | OA type (HYBRID, GOLD, GREEN, etc.) |
| `license` | string | License (CCBY, etc.) |
| `disclaimer` | string | Legal disclaimer |

> **`openAccessInfo` vs `openAccessPdf`:** The `paper` object in Snippet Search (`/snippet/search`) responses uses `openAccessInfo` instead of `openAccessPdf`. `openAccessInfo` does **not** include a `url` field — it only contains `license`, `status`, `disclaimer`. For the PDF URL, look up the paper separately via `/paper/{paper_id}`.

## 8.11 Publication Venue

| Field | Type | Description |
|---|---|---|
| `id` | string | Venue unique ID |
| `name` | string | Venue name |
| `type` | string | Type (`conference`, `journal`, etc.) |
| `alternate_names` | array[string] | Alternative names/abbreviations |
| `url` | string | Venue website |

## 8.12 Fields of Study

**`fieldsOfStudy` vs `s2FieldsOfStudy` differences:**

| Aspect | `fieldsOfStudy` | `s2FieldsOfStudy` |
|---|---|---|
| Type | `array[string]` | `array[object]` |
| Source | Assigned from external sources | External + S2 classification model |
| Structure | `["Computer Science"]` | `[{"category": "CS", "source": "s2-fos-model"}]` |
| `source` values | — | `"external"` or `"s2-fos-model"` |
| Use case | Simple field check | When source distinction is needed |

`s2FieldsOfStudy` includes results from S2's own trained classification model (s2-fos-model), enabling field classification even for papers without external source assignments.

**Available field values (23):**

Computer Science, Medicine, Chemistry, Biology, Materials Science, Physics, Geology, Psychology, Art, History, Geography, Sociology, Business, Political Science, Economics, Philosophy, Mathematics, Engineering, Environmental Science, Agricultural and Food Sciences, Education, Law, Linguistics

## 8.13 Response Wrappers

Each endpoint wraps results in a wrapper model. Four patterns exist based on pagination type:

**Pattern A — offset pagination:**

| Field | Type | Description |
|---|---|---|
| `offset` | integer | Current batch start position |
| `next` | integer | Next batch start position (absent on last page) |
| `data` | array | Result array |

Used by: `CitationBatch`, `ReferenceBatch`, `AuthorBatch`, `AuthorPaperBatch`

**Pattern B — offset + total:**

| Field | Type | Description |
|---|---|---|
| `total` | string | Approximate total result count (may not be exact) |
| `offset` | integer | Current batch start position |
| `next` | integer | Next batch start position (absent on last page) |
| `data` | array | Result array |

Used by: `PaperRelevanceSearchBatch`, `AuthorSearchBatch`

**Pattern C — token-based:**

| Field | Type | Description |
|---|---|---|
| `total` | integer | Approximate total result count |
| `token` | string | Continuation token for next page |
| `data` | array | Result array |

Used by: `PaperBulkSearchBatch`

**Pattern D — simple wrapper (no pagination):**

| Field | Type | Description |
|---|---|---|
| `data` | array | Result array |

Used by: `PaperMatch`

**Endpoint-to-wrapper mapping:**

| Endpoint | Wrapper Model | Pattern |
|---|---|---|
| `GET /paper/search` | `PaperRelevanceSearchBatch` | B |
| `GET /paper/search/bulk` | `PaperBulkSearchBatch` | C |
| `GET /paper/search/match` | `PaperMatch` | D |
| `GET /paper/autocomplete` | `PaperAutocomplete` | Separate (`matches` array) |
| `GET /snippet/search` | `SnippetMatch` | Separate (`data` + `retrievalVersion`) |
| `GET /paper/{id}/citations` | `CitationBatch` | A |
| `GET /paper/{id}/references` | `ReferenceBatch` | A |
| `GET /paper/{id}/authors` | `AuthorBatch` | A |
| `GET /author/search` | `AuthorSearchBatch` | B |
| `GET /author/{id}/papers` | `AuthorPaperBatch` | A |

## 8.14 Special Variant Models

Some endpoints return specialized models different from `BasePaper`/`FullPaper`:

**Title Match Paper** (`/paper/search/match` response):

All `PaperWithLinks` fields plus:

| Field | Type | Description |
|---|---|---|
| `matchScore` | number | Title matching confidence score |

> Differs from `PaperWithLinks` in that `citations`/`references` reference `BasePaper` instead of `PaperInfo`.

**Autocomplete Paper** (`/paper/autocomplete` response):

| Field | Type | Description |
|---|---|---|
| `id` | string | Paper ID |
| `title` | string | Paper title |
| `authorsYear` | string | Author summary + year (e.g., `"Beltagy et al., 2019"`) |

> A very lightweight structure compared to regular Paper models. Optimized for autocomplete UI.

**PaperInfo** (internal reference model):

| Field | Type | Description |
|---|---|---|
| `paperId` | string | S2 paper ID |
| `corpusId` | integer | S2 corpus ID |
| `url` | string | S2 website URL |
| `title` | string | Paper title |
| `venue` | string | Venue name |
| `publicationVenue` | object | Venue details |
| `year` | integer | Publication year |
| `authors` | array[AuthorInfo] | Author list |

> Used as items within `PaperWithLinks`' `citations`/`references`. A subset of `BasePaper`.

**AuthorInfo** (author summary model):

| Field | Type | Description |
|---|---|---|
| `authorId` | string | S2 author ID |
| `name` | string | Author name |

> The type of each item in `BasePaper`/`FullPaper`'s `authors` array. An abbreviated version of `Author` (8.3).

**Request body models:**

| Model | Purpose | Fields |
|---|---|---|
| `PaperBatch` | `POST /paper/batch` request body | `ids`: array of paper ID strings (max 500) |
| `AuthorIdList` | `POST /author/batch` request body | `ids`: array of author ID strings (max 1,000) |

