---
title: "5. Author API"
description: "Author search, detail lookup, batch lookup, papers by author"
---

# 5. Author API

## 5.1 Author Search

Search for authors by name. Max 10MB response.

```
GET /graph/v1/author/search
```

**Parameters:**

| Name | Type | Required | Description |
|---|---|---|---|
| `query` | string | Yes | Author name search query |
| `fields` | string | | Fields to return |
| `offset` | integer | | Start position |
| `limit` | integer | | Max results (default 100, max 1,000) |

> **Note**: Requesting the `papers` field returns **all papers** for each author, so set `limit` appropriately to manage response size and latency.

> **Note**: No special query syntax is supported. Names containing hyphens (-) won't match; replace with spaces instead.

**Examples:**
```bash
# Basic search (authorId + name, default 100)
curl "https://api.semanticscholar.org/graph/v1/author/search?query=adam+smith"

# With fields + papers + reduced limit
curl "https://api.semanticscholar.org/graph/v1/author/search?query=adam+smith&fields=name,url,papers.title,papers.year&limit=5"

# Non-existent name → total=0, data=[]
curl "https://api.semanticscholar.org/graph/v1/author/search?query=totalGarbageNonsense"
```

**Response schema:**
```json
{
  "total": 482,
  "offset": 0,
  "next": 100,
  "data": [ { "authorId": "...", "name": "..." } ]
}
```

| Field | Type | Description |
|---|---|---|
| `total` | string | Approximate total result count (may not be exact) |
| `offset` | integer | Current start position |
| `next` | integer | Next page start position (absent on last page) |
| `data` | array | Array of author objects |

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable query=hinton api/graph/author-search.hurl
```

Change the query via `--variable`. Add `--json` flag to output captured values as JSON.

## 5.2 Author Detail

Retrieve detailed information for a specific author. Max 10MB response.

```
GET /graph/v1/author/{author_id}
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `author_id` | path | string | Yes | Author ID |
| `fields` | query | string | | Fields to return |

**Examples:**
```bash
# Basic (authorId + name)
curl "https://api.semanticscholar.org/graph/v1/author/1741101"

# URL + paper list (default subfields: paperId + title)
curl "https://api.semanticscholar.org/graph/v1/author/1741101?fields=url,papers"

# Paper abstracts + paper authors (nested)
curl "https://api.semanticscholar.org/graph/v1/author/1741101?fields=url,papers.abstract,papers.authors"
```

**Available fields** (Author model):

| Field | Type | Description | Example |
|---|---|---|---|
| `authorId` | string | S2 unique author ID | `"1741101"` |
| `externalIds` | object | ORCID/DBLP external IDs | `{"DBLP": [123]}` |
| `url` | string | S2 profile URL | `"https://www.semanticscholar.org/author/1741101"` |
| `name` | string | Author name | `"Oren Etzioni"` |
| `affiliations` | array | Affiliated institutions | `["Allen Institute for AI"]` |
| `homepage` | string | Personal homepage | `"https://allenai.org/"` |
| `paperCount` | string | Total paper count | `10` |
| `citationCount` | string | Total citation count | `50` |
| `hIndex` | string | h-index | `5` |

> **Note**: `paperCount`, `citationCount`, `hIndex` are typed as `string` in the Swagger schema, but actual responses return numeric values.

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable author_id=1741101 api/graph/author-detail.hurl
```

Change the author ID via `--variable`. Add `--json` flag to output captured values as JSON.

## 5.3 Author Batch Lookup

Look up multiple authors at once.

```
POST /graph/v1/author/batch
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `fields` | query | string | | Fields to return |

`authorId` is always returned. When omitted, only `authorId` + `name` are returned.

**fields examples:**
```
fields=name,affiliations,papers          # name, affiliations, papers
fields=url,papers.year,papers.authors    # URL, paper year/authors
```

**Request body:**
```json
{
  "ids": ["1741101", "2108700"]
}
```

**Limitations:**
- Max **1,000** Author IDs
- Single response max **10MB**

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable author_id=1741101 api/graph/author-batch.hurl
```

Change the author ID via `--variable`. Add `--json` flag to output captured values as JSON.

## 5.4 Author Papers

Retrieve papers by a specific author in batch.

```
GET /graph/v1/author/{author_id}/papers
```

> **Note**: Citations/references within the batch are limited to the **most recent 10,000**. For complete citations, use the `/paper/{paper_id}/citations` endpoint separately.

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `author_id` | path | string | Yes | Author ID |
| `fields` | query | string | | Fields to return |
| `offset` | query | integer | | Start position |
| `limit` | query | integer | | Max results (default 100, max 1,000) |
| `publicationDateOrYear` | query | string | | Publication date range filter |

**Examples:**
```bash
# Basic (first 100, paperId + title)
curl "https://api.semanticscholar.org/graph/v1/author/1741101/papers"

# With fields + limit
curl "https://api.semanticscholar.org/graph/v1/author/1741101/papers?fields=url,year,authors&limit=2"

# Nested citation authors + offset
curl "https://api.semanticscholar.org/graph/v1/author/1741101/papers?fields=citations.authors&offset=260"
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable author_id=1741101 api/graph/author-papers.hurl
```

Change the author ID via `--variable`. Add `--json` flag to output captured values as JSON.

