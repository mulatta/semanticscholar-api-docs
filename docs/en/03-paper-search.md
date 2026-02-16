---
title: "3. Paper Search API"
description: "5 paper search endpoints: relevance search, bulk search, title match, autocomplete, snippet search"
---

# 3. Paper Search API

## 3.1 Paper Relevance Search

Search papers by relevance. The most basic search endpoint.

```
GET /graph/v1/paper/search
```

**Parameters:**

| Name | Type | Required | Description |
|---|---|---|---|
| `query` | string | Yes | Search query (plain text) |
| `fields` | string | | Fields to return (comma-separated) |
| `offset` | integer | | Pagination start position (default 0) |
| `limit` | integer | | Max results (default 100, max 100) |
| `publicationDateOrYear` | string | | Publication date range |
| `year` | string | | Publication year range |
| `venue` | string | | Venue filter (comma-separated, ISO4 abbreviations accepted) |
| `fieldsOfStudy` | string | | Field of study filter |
| `publicationTypes` | string | | Publication type filter |
| `openAccessPdf` | string | | Filter for papers with open access PDF (include parameter without value) |
| `minCitationCount` | string | | Minimum citation count (e.g., `200`) |

**Response schema:**
```json
{
  "total": 1000,
  "offset": 0,
  "next": 10,
  "data": [ { "paperId": "...", "title": "..." } ]
}
```

**Limitations:**
- Returns at most 1,000 relevance-ranked results
- Single response max 10MB

**Example:**
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/search?query=transformer+attention&fields=title,year,citationCount&limit=5"
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable query=transformer+attention api/graph/paper-search.hurl
```

Change the search query via `--variable`. Add `--json` flag to output captured values as JSON.

## 3.2 Paper Bulk Search

Optimized for large-scale paper data retrieval. Similar to relevance search but **without relevance ranking**.

```
GET /graph/v1/paper/search/bulk
```

**Characteristics:**
- Text query is required and supports boolean logic (empty string allowed)
- Returns up to **1,000 results** per call
- If more results exist, a `token` is returned
- Can page through up to **10,000,000 results** (beyond that, use Datasets API)
- Nested data (`citations`, `references`, etc.) is **not available** on this endpoint

**Parameters:**

| Name | Type | Required | Description |
|---|---|---|---|
| `query` | string | Yes | Search query (targets title+abstract, English stemming applied, boolean syntax supported) |
| `token` | string | | Pagination token (from previous response, new token issued per call) |
| `fields` | string | | Fields to return |
| `sort` | string | | Sort criteria (see below) |
| `publicationDateOrYear` | string | | Publication date range |
| `year` | string | | Publication year range |
| `venue` | string | | Venue filter |
| `fieldsOfStudy` | string | | Field of study filter |
| `publicationTypes` | string | | Publication type filter |
| `openAccessPdf` | string | | Open access PDF filter |
| `minCitationCount` | string | | Minimum citation count |

**Query syntax (boolean search):**

| Operator | Meaning | Example |
|---|---|---|
| `+` (default) | AND | `fish ladder` → "fish" AND "ladder" |
| `\|` | OR | `fish \| ladder` → "fish" OR "ladder" |
| `-` | NOT | `fish -ladder` → "fish" but NOT "ladder" |
| `"..."` | Phrase search | `"fish ladder"` → exact phrase |
| `*` | Prefix matching | `trans*` → transformer, translation, etc. |
| `(...)` | Grouping | `(fish ladder) \| outflow` |
| `~N` (after word) | Edit distance N (default 2) | `fish~` → fish, fist, fihs, etc. |
| `~N` (after phrase) | Max N token distance between words (default 2) | `"fish ladder"~3` → "fish is on a ladder" |

**sort parameter:**

Format: `field:order` (default `paperId:asc`)

| Sort Field | Example | Description |
|---|---|---|
| `paperId` | `paperId` or `paperId:asc` | By ID (default, safe during data changes while paging) |
| `publicationDate` | `publicationDate:asc` | Oldest papers first |
| `citationCount` | `citationCount:desc` | Most cited papers first |

> Records with no sort value appear last regardless of asc/desc. The default `paperId` sort is the most stable during paging. Ties are broken by `paperId`.

**Response schema:**
```json
{
  "total": 50000,
  "token": "NEXT_PAGE_TOKEN",
  "data": [ ... ]
}
```

**Differences from relevance search:**

| Aspect | `/paper/search` | `/paper/search/bulk` |
|---|---|---|
| Sorting | Relevance order (fixed) | `paperId`, `publicationDate`, `citationCount` selectable |
| Pagination | offset/limit (max 100) | Token-based (max 1,000/call) |
| Max results | Offset-based limit | 10,000,000 |
| Nested data | citations, references available | **Not available** |
| Query syntax | Plain text | Boolean operators supported |
| Use case | User-facing search | Large-scale data collection |

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable query=transformer+attention api/graph/paper-bulk-search.hurl
```

Change the search query via `--variable`. Add `--json` flag to output captured values (`total`, `token`, etc.) as JSON.

## 3.3 Paper Title Match

Finds the **single best-matching paper** for a given title. Ideal for retrieving S2 metadata when you already know the paper title.

```
GET /graph/v1/paper/search/match
```

**Characteristics:**
- **Always returns a single result** (the paper with the highest match score)
- Response includes a `matchScore` field
- Returns 404 on match failure: `"Title match not found"`

**Parameters:**

| Name | Type | Required | Description |
|---|---|---|---|
| `query` | string | Yes | Paper title (or similar string) |
| `fields` | string | | Fields to return |
| `publicationDateOrYear` | string | | Publication date range |
| `year` | string | | Publication year range |
| `venue` | string | | Venue filter |
| `fieldsOfStudy` | string | | Field of study filter |
| `publicationTypes` | string | | Publication type filter |
| `openAccessPdf` | string | | Open access PDF filter |
| `minCitationCount` | string | | Minimum citation count |

**Examples:**
```bash
# Find paper by title
curl "https://api.semanticscholar.org/graph/v1/paper/search/match?query=Attention+Is+All+You+Need&fields=title,year,authors"

# Non-existent title → 404
curl "https://api.semanticscholar.org/graph/v1/paper/search/match?query=totalGarbageNonsense"
```

**Response schema:**
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

> Wrapped in a `data` array but always contains 0–1 results. `matchScore` is the title matching confidence score.

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable query=Attention+Is+All+You+Need api/graph/paper-title-match.hurl
```

Specify the paper title via `--variable query=...`. Add `--json` flag to output captured values (`paper_id`, `match_score`, etc.) as JSON.

## 3.4 Paper Autocomplete

For interactive search autocompletion. Returns minimal information (titles, etc.) quickly for partial queries.

```
GET /graph/v1/paper/autocomplete
```

**Parameters:**

| Name | Type | Required | Description |
|---|---|---|---|
| `query` | string | Yes | Partial query string (truncated to 100 characters) |

**Response schema:**
```json
{
  "matches": [
    { "id": "...", "title": "...", "authorsYear": "Beltagy et al., 2019" }
  ]
}
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable query=attention+is+all api/graph/paper-autocomplete.hurl
```

Specify the partial query via `--variable query=...`. Add `--json` flag to output autocomplete results as JSON.

## 3.5 Snippet Search

Searches **full-text snippets** from paper bodies. Can search beyond titles/abstracts into the actual body text. Returns excerpts of approximately 500 words, excluding figure captions and bibliographies.

```
GET /graph/v1/snippet/search
```

**Limitations:**
- `query` is required
- Default 10 results when `limit` is not specified
- `limit` max **1,000**

**Parameters:**

| Name | Type | Required | Description |
|---|---|---|---|
| `query` | string | Yes | Search query |
| `limit` | integer | | Max results (default 10, max 1,000) |
| `fields` | string | | Snippet element fields to return (see below) |
| `paperIds` | string | | Restrict to specific papers (comma-separated, max ~100, all ID formats supported) |
| `authors` | string | | Author name filter (comma-separated, AND logic, fuzzy matching, max 10) |
| `minCitationCount` | string | | Minimum citation count |
| `insertedBefore` | string | | Index date filter (`YYYY-MM-DD`, `YYYY-MM`, `YYYY`) |
| `publicationDateOrYear` | string | | Publication date range |
| `year` | string | | Publication year range |
| `venue` | string | | Venue filter |
| `fieldsOfStudy` | string | | Field of study filter |

**`authors` filter details:**
- AND logic: `authors=galileo,kepler` → papers containing **both** authors
- Fuzzy matching: matches similar names within edit distance 2 (keppler → kepler)
- For OR search, perform separate searches per author
- Max 10 authors, exceeding returns 400 error

**`fields` parameter (snippet-specific):**

`paper` and `score` are always returned. Use `fields` to control snippet subfields:

```
fields=snippet.text                              # text only
fields=snippet.text,snippet.snippetKind          # text + location kind
fields=snippet.annotations.sentences             # sentence annotations only
```

Default fields (when fields not specified):
- `snippet.text`, `snippet.snippetKind`, `snippet.section`
- `snippet.snippetOffset` (includes start, end)
- `snippet.annotations.refMentions` (start, end, matchedPaperCorpusId)
- `snippet.annotations.sentences` (start, end)

**Response structure:**

Each result includes:

| Field | Description |
|---|---|
| `snippet.text` | Body text excerpt related to the query |
| `snippet.snippetKind` | Location: `title`, `abstract`, `body` |
| `snippet.section` | Section name when from body |
| `snippet.snippetOffset` | Position information within the paper (`start`, `end`) |
| `snippet.annotations.refMentions` | Reference mention info (`start`, `end`, `matchedPaperCorpusId`) |
| `snippet.annotations.sentences` | Sentence boundary info (`start`, `end`) |
| `score` | Relevance score (e.g., `0.562`) |
| `paper` | Paper information (`corpusId`, `title`, `authors`, `openAccessInfo`) |
| `retrievalVersion` | Search engine version info |

**Example:**
```bash
curl "https://api.semanticscholar.org/graph/v1/snippet/search?query=The+literature+graph+is+a+property+graph&limit=1"
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable query=literature+graph+property+graph api/graph/snippet-search.hurl
```

Change the search query via `--variable query=...`. Add `--json` flag to output captured values (snippet text, score, etc.) as JSON.

