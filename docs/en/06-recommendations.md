---
title: "6. Recommendations API"
description: "Single-paper and multi-paper (positive/negative) recommendations"
---

# 6. Recommendations API

Base URL: `https://api.semanticscholar.org/recommendations/v1`

## 6.1 Single-Paper Recommendations

Get similar paper recommendations based on a single paper.

```
GET /recommendations/v1/papers/forpaper/{paper_id}
```

**Parameters:**

| Name | Location | Type | Required | Default | Description |
|---|---|---|---|---|---|
| `paper_id` | path | string | Yes | | Seed paper ID |
| `limit` | query | integer | | 100 | Number of recommendations (max 500) |
| `fields` | query | string | | | Fields to return |
| `from` | query | string | | `recent` | Recommendation pool: `recent` or `all-cs` |

**Recommendation pool (`from`) options:**

| Value | Description |
|---|---|
| `recent` | Recommend from recent papers pool (default) |
| `all-cs` | Recommend from all CS papers pool |

**Example:**
```bash
curl "https://api.semanticscholar.org/recommendations/v1/papers/forpaper/649def34f8be52c8b66281af98ae884c09aef38b?fields=title,year&limit=5&from=recent"
```

**Response:**
```json
{
  "recommendedPapers": [
    { "paperId": "...", "title": "...", "year": 2024 }
  ]
}
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b api/recommendations/single-paper.hurl
```

Use `--variable paper_id=...` to change the seed paper ID. Add `--json` to output captured values (`rec_count`, `first_paper_id`) as JSON.

## 6.2 Multi-Paper Recommendations (Positive/Negative)

Get tailored recommendations by providing multiple papers as positive (similar to) and negative (avoid) examples.

```
POST /recommendations/v1/papers/
```

**Query parameters:**

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `limit` | integer | | 100 | Number of recommendations (max 500) |
| `fields` | string | | | Fields to return |

**Request body:**
```json
{
  "positivePaperIds": [
    "649def34f8be52c8b66281af98ae884c09aef38b"
  ],
  "negativePaperIds": [
    "ArXiv:1805.02262"
  ]
}
```

- `positivePaperIds`: "I want papers similar to these" — the recommendation basis
- `negativePaperIds`: "I don't want papers like these" — direction to avoid

> **Note**: Both fields are optional in the Swagger schema, but in practice `positivePaperIds` requires at least one paper ID.

> Various ID formats can be mixed (S2 ID, ArXiv, DOI, etc.)

**Response:**
```json
{
  "recommendedPapers": [
    { "paperId": "...", "title": "...", "year": 2024 }
  ]
}
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY api/recommendations/multi-paper.hurl
```

Paper IDs are defined directly in the hurl file's JSON body. To change `positivePaperIds`/`negativePaperIds`, edit `api/recommendations/multi-paper.hurl`. Add `--json` to output captured values (`rec_count`, `first_paper_id`) as JSON.

