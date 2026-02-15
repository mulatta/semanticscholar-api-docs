---
title: "2. Authentication & Common"
description: "API key, Base URL, fields parameter, pagination, ID formats, filters, error codes"
---

# 2. Authentication & Common

## 2.1 API Key

The API can be used without an API key, but rate limits apply. Using an API key provides higher throughput.

```
x-api-key: YOUR_API_KEY
```

> **Note**: The header name `x-api-key` is **case-sensitive**.

## 2.2 Common Request Format

- Content-Type: `application/json`
- Accept: `application/json`
- All special characters must be URL-encoded

## 2.3 `fields` Parameter

A core parameter used across nearly all endpoints. Specify a comma-separated list of fields to control response size.

```
?fields=title,authors,year,citationCount
```

**Default behavior:**
- When `fields` is omitted → papers: only `paperId` + `title`, authors: only `authorId` + `name`
- `fields` is a **single-value string** parameter (not multi-value)

**Nested fields (subfields):**

Use dot notation (`.`) to specify subfields:

| Parent Field | Default Subfields | Additional Subfield Examples |
|---|---|---|
| `authors` | `authorId`, `name` | `author.url`, `author.paperCount`, `author.hIndex` |
| `citations` | `paperId`, `title` | `citations.abstract`, `citations.authors`, `citations.year` |
| `references` | `paperId`, `title` | `references.abstract`, `references.authors` |
| `embedding` | SPECTER v1 (default) | `embedding.specter_v2` (select v2 embedding) |

**Examples:**
```
fields=title,url                                    # basic fields only
fields=title,embedding.specter_v2                   # SPECTER v2 embedding
fields=title,authors,citations.title,citations.abstract  # authors + citation title/abstract
fields=url,papers.year,papers.authors               # paper subfields in author API
```

> **Note**: For `/snippet/search`, fields use the form `snippet.text`, `snippet.snippetKind`. `paper` and `score` are always returned and cannot be specified.

## 2.4 Pagination

Two pagination methods exist:

| Method | Parameters | Used By |
|---|---|---|
| **Offset-based** | `offset`, `limit` | `/paper/search`, `/author/search`, citations, references, authors |
| **Token(cursor)-based** | `token` | `/paper/search/bulk` |

**Offset-based example:**
```
GET /paper/search?query=LLM&offset=0&limit=10
GET /paper/search?query=LLM&offset=10&limit=10
```

**Token-based example:**
```
GET /paper/search/bulk?query=LLM
→ Response includes "token": "abc123"
GET /paper/search/bulk?query=LLM&token=abc123
```

## 2.5 Paper ID Formats

Various external IDs can be used to specify papers:

| Format | Example |
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

Supported URL sites: semanticscholar.org, arxiv.org, aclweb.org, acm.org, biorxiv.org

## 2.6 Common Filter Parameters

Filters shared across search endpoints (`/paper/search`, `/paper/search/bulk`, `/paper/search/match`, `/snippet/search`):

### `publicationDateOrYear`

Date range format: `<start>:<end>` (each in `YYYY-MM-DD` format, both sides optional)

| Example | Meaning |
|---|---|
| `2019-03-05` | March 5, 2019 only |
| `2019-03` | All of March 2019 |
| `2019` | All of 2019 |
| `2016-03-05:2020-06-06` | 2016.03.05 to 2020.06.06 |
| `1981-08-25:` | After 1981.08.25 |
| `:2015-01` | Up to end of January 2015 |
| `2015:2020` | 2015.01.01 to 2020.12.31 |

> Papers with unknown exact publication dates are treated as January 1st of that year. Even when `publicationDate` is null, `year` is always present.

### `year`

Simple year-based filter:

| Example | Meaning |
|---|---|
| `2019` | Year 2019 |
| `2016-2020` | 2016 to 2020 |
| `2010-` | 2010 and later |
| `-2015` | 2015 and earlier |

### `publicationTypes`

Publication type filter (comma-separated, OR logic):

| Value | Description |
|---|---|
| `Review` | Review article |
| `JournalArticle` | Journal article |
| `CaseReport` | Case report |
| `ClinicalTrial` | Clinical trial |
| `Conference` | Conference paper |
| `Dataset` | Dataset |
| `Editorial` | Editorial |
| `LettersAndComments` | Letters/comments |
| `MetaAnalysis` | Meta-analysis |
| `News` | News |
| `Study` | Study |
| `Book` | Book |
| `BookSection` | Book section |

Example: `publicationTypes=Review,JournalArticle` → papers that are Review **or** JournalArticle

### `fieldsOfStudy`

Field of study filter (comma-separated, OR logic):

Computer Science, Medicine, Chemistry, Biology, Materials Science, Physics, Geology, Psychology, Art, History, Geography, Sociology, Business, Political Science, Economics, Philosophy, Mathematics, Engineering, Environmental Science, Agricultural and Food Sciences, Education, Law, Linguistics

Example: `fieldsOfStudy=Physics,Mathematics` → papers in Physics **or** Mathematics

### `venue`

Venue filter (comma-separated). Both full names and ISO4 abbreviations are accepted:

Example: `venue=Nature,Radiology` or `venue=N. Engl. J. Med.`

### `openAccessPdf`

Filter for papers with open access PDF. **Include the parameter without a value**:

```
?query=LLM&openAccessPdf
```

### `minCitationCount`

Minimum citation count filter:

```
?query=LLM&minCitationCount=200
```

## 2.7 Response Size Limit

- Maximum single response size for all endpoints: **10MB**
- On exceeding: 400 error `"Response would exceed maximum size..."`
- Resolution: reduce `limit`, minimize `fields`, split batches

## 2.8 Error Responses

| Code | Meaning | error Field Example |
|---|---|---|
| **400** | Bad request | `"Unrecognized or unsupported fields: [bad1, bad2]"` |
| **400** | Invalid parameter | `"Unacceptable query params: [badK1=badV1]"` |
| **400** | Response too large | `"Response would exceed maximum size..."` (when exceeding 10MB) |
| **404** | Not found | `"Paper with id ### not found"` |
| **404** | Title match failed | `"Title match not found"` (`/paper/search/match` only) |

