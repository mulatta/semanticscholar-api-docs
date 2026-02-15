---
title: "4. Paper Detail API"
description: "Single/batch paper lookup, citations, references, author lists"
---

# 4. Paper Detail API

## 4.1 Single Paper Lookup

Retrieve detailed information for a specific paper. Returns up to 10MB.

```
GET /graph/v1/paper/{paper_id}
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `paper_id` | path | string | Yes | Paper ID (see [2.5 Paper ID Formats](#25-paper-id-formats)) |
| `fields` | query | string | | Fields to return |

**Examples:**
```bash
# Basic lookup (paperId + title only)
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b"

# With specific fields
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=url,year,authors"

# Nested request for citation authors
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=citations.authors"

# Lookup by DOI
curl "https://api.semanticscholar.org/graph/v1/paper/DOI:10.18653/v1/N18-3011?fields=title,citationCount"

# Lookup by ArXiv ID + TLDR
curl "https://api.semanticscholar.org/graph/v1/paper/ARXIV:2106.15928?fields=title,tldr"

# Request SPECTER v2 embedding
curl "https://api.semanticscholar.org/graph/v1/paper/649def34f8be52c8b66281af98ae884c09aef38b?fields=title,embedding.specter_v2"
```

**Available fields** (FullPaper model):

`paperId` (always returned), `corpusId`, `externalIds`, `url`, `title`, `abstract`, `venue`, `publicationVenue`, `year`, `referenceCount`, `citationCount`, `influentialCitationCount`, `isOpenAccess`, `openAccessPdf`, `fieldsOfStudy`, `s2FieldsOfStudy`, `publicationTypes`, `publicationDate`, `journal`, `citationStyles`, `authors`, `citations`, `references`, `embedding`, `tldr`, `textAvailability`

## 4.2 Paper Batch Lookup

Look up up to 500 papers in a single request.

```
POST /graph/v1/paper/batch
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `fields` | query | string | | Fields to return |

**Request body:**
```json
{
  "ids": [
    "649def34f8be52c8b66281af98ae884c09aef38b",
    "ARXIV:2106.15928",
    "DOI:10.18653/v1/N18-3011"
  ]
}
```

> Different ID formats can be mixed in the `ids` array.

**Example:**
```bash
curl -X POST "https://api.semanticscholar.org/graph/v1/paper/batch?fields=title,year,citationCount" \
  -H "Content-Type: application/json" \
  -d '{"ids": ["ARXIV:2106.15928", "DOI:10.1145/3132847.3133079"]}'
```

**Limitations:**
- Max **500** Paper IDs
- Single response max **10MB**
- Max **9,999** citations/references per paper

## 4.3 Paper Citations

Retrieve the list of papers that cite this paper (i.e., this paper appears in their references).

```
GET /graph/v1/paper/{paper_id}/citations
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `paper_id` | path | string | Yes | Paper ID |
| `fields` | query | string | | Fields to return |
| `offset` | query | integer | | Start position (default 0) |
| `limit` | query | integer | | Max results (default 100, max 1,000) |
| `publicationDateOrYear` | query | string | | Publication date range filter |

**fields usage:**

Request `citingPaper` subfields directly as regular fields:

```
fields=contexts,intents,isInfluential,abstract    # citingPaper's abstract
fields=contexts,title,authors                     # citingPaper's title, authors
```

**Examples:**
```bash
# Basic (citingPaper's paperId + title)
curl ".../paper/649def.../citations"

# Citation context + intent + abstract
curl ".../paper/649def.../citations?fields=contexts,intents,isInfluential,abstract&offset=200&limit=10"

# Citing paper authors
curl ".../paper/649def.../citations?fields=authors&offset=1500&limit=500"
```

**Response structure (Citation model):**

| Field | Description |
|---|---|
| `citingPaper` | Details of the citing paper |
| `contexts` | Array of citation context text |
| `intents` | Array of citation intents (methodology, background, etc.) |
| `contextsWithIntent` | Array of combined context+intent objects |
| `isInfluential` | Whether the citation is influential |

## 4.4 Paper References

Retrieve the list of papers referenced by this paper (i.e., this paper's bibliography).

```
GET /graph/v1/paper/{paper_id}/references
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `paper_id` | path | string | Yes | Paper ID |
| `fields` | query | string | | Fields to return |
| `offset` | query | integer | | Start position (default 0) |
| `limit` | query | integer | | Max results (default 100, max 1,000) |

**Response structure (Reference model):**

| Field | Description |
|---|---|
| `citedPaper` | Details of the referenced paper |
| `contexts` | Array of reference context text |
| `intents` | Array of citation intents |
| `contextsWithIntent` | Array of combined context+intent objects |
| `isInfluential` | Whether the citation is influential |

**Citations vs References:**

| Aspect | Citations | References |
|---|---|---|
| Direction | Papers that **cite** this paper | Papers that this paper **cites** |
| Analogy | "Who cited me?" | "Who did I cite?" |
| Response object key | `citingPaper` | `citedPaper` |
| `publicationDateOrYear` filter | Supported | Not supported |

## 4.5 Paper Authors

Retrieve the author list for a specific paper.

```
GET /graph/v1/paper/{paper_id}/authors
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `paper_id` | path | string | Yes | Paper ID |
| `fields` | query | string | | Fields to return |
| `offset` | query | integer | | Start position (default 0) |
| `limit` | query | integer | | Max results (default 100, max 1,000) |

**fields usage:**

Specify `papers` subfields with `.`:

```
fields=name,affiliations,papers                # name + affiliations + paper list
fields=url,papers.year,papers.authors          # author URL + paper year/authors
```

**Examples:**
```bash
# Basic (authorId + name)
curl ".../paper/649def.../authors"

# Affiliations + paper list (limit 2)
curl ".../paper/649def.../authors?fields=affiliations,papers&limit=2"

# Author's paper years + paper authors (with offset)
curl ".../paper/649def.../authors?fields=url,papers.year,papers.authors&offset=2"
```

