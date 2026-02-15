---
title: "Appendix"
description: "Full endpoint summary table + 6 practical usage patterns (citation graph, bulk collection, co-author network, recommendations, incremental update, endpoint selection)"
---

# Appendix A: Full Endpoint Summary

| # | Service | Method | Endpoint | Description |
|---|---|---|---|---|
| 1 | Graph | GET | `/paper/search` | Paper relevance search |
| 2 | Graph | GET | `/paper/search/bulk` | Paper bulk search |
| 3 | Graph | GET | `/paper/search/match` | Paper title match |
| 4 | Graph | GET | `/paper/autocomplete` | Paper autocomplete |
| 5 | Graph | GET | `/snippet/search` | Body text snippet search |
| 6 | Graph | GET | `/paper/{paper_id}` | Single paper lookup |
| 7 | Graph | POST | `/paper/batch` | Paper batch lookup |
| 8 | Graph | GET | `/paper/{paper_id}/citations` | Citation list |
| 9 | Graph | GET | `/paper/{paper_id}/references` | Reference list |
| 10 | Graph | GET | `/paper/{paper_id}/authors` | Paper author list |
| 11 | Graph | GET | `/author/search` | Author search |
| 12 | Graph | GET | `/author/{author_id}` | Author detail |
| 13 | Graph | POST | `/author/batch` | Author batch lookup |
| 14 | Graph | GET | `/author/{author_id}/papers` | Papers by author |
| 15 | Recs | GET | `/papers/forpaper/{paper_id}` | Single-paper recommendations |
| 16 | Recs | POST | `/papers/` | Multi-paper recommendations |
| 17 | Data | GET | `/release/` | Release list |
| 18 | Data | GET | `/release/{release_id}` | Release detail |
| 19 | Data | GET | `/release/{release_id}/dataset/{dataset_name}` | Dataset download links |
| 20 | Data | GET | `/diffs/{start_release_id}/to/{end_release_id}/{dataset_name}` | Incremental update diff |

---

# Appendix B: Practical Usage Patterns

## B.1 Citation Graph Traversal (2-hop)

Explore papers cited by papers that cite a given paper:

```python
import requests

BASE = "https://api.semanticscholar.org/graph/v1"
PAPER_ID = "649def34f8be52c8b66281af98ae884c09aef38b"

# 1-hop: papers that cite this paper
citations = requests.get(
    f"{BASE}/paper/{PAPER_ID}/citations",
    params={"fields": "citingPaper.paperId,citingPaper.title", "limit": 10}
).json()

# 2-hop: references of the citing papers
for c in citations["data"]:
    citing_id = c["citingPaper"]["paperId"]
    refs = requests.get(
        f"{BASE}/paper/{citing_id}/references",
        params={"fields": "citedPaper.title", "limit": 5}
    ).json()
```

## B.2 Bulk Collection of Highly-Cited Papers in a Specific Field

```python
import requests

BASE = "https://api.semanticscholar.org/graph/v1"
papers = []
token = None

while True:
    params = {
        "query": "large language model",
        "fields": "title,year,citationCount,authors",
        "fieldsOfStudy": "Computer Science",
        "minCitationCount": "100",
        "sort": "citationCount:desc",
    }
    if token:
        params["token"] = token

    resp = requests.get(f"{BASE}/paper/search/bulk", params=params).json()
    papers.extend(resp.get("data", []))
    token = resp.get("token")

    if not token:
        break

print(f"Total: {len(papers)} papers")
```

## B.3 Co-Author Network

```python
import requests
from collections import Counter

BASE = "https://api.semanticscholar.org/graph/v1"
AUTHOR_ID = "1741101"

# Collect co-authors from all papers by this author
papers = requests.get(
    f"{BASE}/author/{AUTHOR_ID}/papers",
    params={"fields": "authors", "limit": 1000}
).json()

coauthors = Counter()
for paper in papers["data"]:
    for author in paper.get("authors", []):
        if author["authorId"] != AUTHOR_ID:
            coauthors[author["name"]] += 1

# Top co-authors
for name, count in coauthors.most_common(10):
    print(f"{name}: {count} papers")
```

## B.4 Recommendations with Positive/Negative Examples

Distinguish papers you liked from those you're not interested in for tailored recommendations:

```python
import requests

resp = requests.post(
    "https://api.semanticscholar.org/recommendations/v1/papers/",
    params={"fields": "title,year,citationCount,openAccessPdf", "limit": 20},
    json={
        "positivePaperIds": [
            "ARXIV:2005.14165",  # GPT-3
            "ARXIV:2303.08774",  # GPT-4
        ],
        "negativePaperIds": [
            "ARXIV:1810.04805",  # BERT (not interested)
        ]
    }
).json()

for paper in resp["recommendedPapers"]:
    pdf = paper.get("openAccessPdf", {})
    print(f"[{paper['year']}] {paper['title']} (citations: {paper['citationCount']})")
    if pdf:
        print(f"  PDF: {pdf.get('url')}")
```

## B.5 Dataset Incremental Update Workflow

```bash
# 1. Check current releases
curl "https://api.semanticscholar.org/datasets/v1/release/" | jq '.[-3:]'

# 2. Check latest release info
curl "https://api.semanticscholar.org/datasets/v1/release/latest" | jq '.release_id'

# 3. Download diffs (held release → latest)
curl "https://api.semanticscholar.org/datasets/v1/diffs/2023-08-01/to/latest/papers" | jq '.diffs | length'
```

## B.6 Endpoint Selection Guide

| Scenario | Recommended Endpoint | Reason |
|---|---|---|
| User search UI | `/paper/search` | Relevance-ranked, offset pagination |
| Large-scale data collection | `/paper/search/bulk` | 1,000/call, up to 10M, boolean queries |
| Find paper by title | `/paper/search/match` | Single best-match result |
| Search autocomplete | `/paper/autocomplete` | Fast response, minimal data |
| Full-text body search | `/snippet/search` | title/abstract/body text excerpts |
| Specific paper metadata | `/paper/{id}` | Full field access |
| Batch lookup (hundreds) | `POST /paper/batch` | Single request batch processing |
| Citation/reference analysis | `/paper/{id}/citations` + `/references` | Context, intent, influence included |
| Similar paper discovery | `GET /papers/forpaper/{id}` | Simple single-paper based |
| Custom recommendations | `POST /papers/` | Positive/negative examples |
| Full corpus analysis | Datasets API | Offline large-scale analysis |

---

# Appendix C: Undocumented Bulk Search Pagination Limitations

> **⚠ Empirical Finding**
> This section describes behavior NOT documented in the official Semantic Scholar API documentation. These findings were empirically observed during large-scale collection experiments targeting the Biology domain (~477K papers/year) in February 2025. Server-side behavior may change without notice.

## C.1 Silent Rate Limiting

The Bulk Search API (`/paper/search/bulk`) terminates pagination early by returning **`token: null` with HTTP 200** instead of HTTP 429 when the rate limit budget is exhausted. The official documentation states that `token` is null when "no more results can be fetched," but in practice, `token: null` is also returned when results remain but the rate limit budget is depleted.

**Observed results (Biology domain, January 2024, 38,002 papers reported):**

| Delay between requests | Papers collected | Coverage | Notes |
|------------------------|-----------------|----------|-------|
| 0s | 1,847 | 5% | 429 → tenacity retry → cumulative delay |
| 0.3s | 4,861 | 13% | Budget depleted by prior experiments |
| 1s | 13,966 | 37% | Optimal on cold start |
| 3s | 8,961 | 24% | Excessive delay worsened results |

## C.2 Rate Limit Budget Characteristics

1. **Shared across endpoints**: Bulk Search (`/paper/search/bulk`) and Batch (`POST /paper/batch`) calls consume the **same budget**. Heavy Batch API usage immediately before Bulk Search causes shorter pagination.

2. **Sliding window recovery**: The budget recovers over time. Within a single run processing multiple months, early months show lower coverage while later months improve as the budget recovers.

   | Order | Month | Reported | Collected | Coverage | Prior Batch calls |
   |-------|-------|----------|-----------|----------|-------------------|
   | 1 | 2024-01 | 38,002 | 4,861 | 13% | — (residual from prior experiments) |
   | 2 | 2024-02 | 34,690 | 4,903 | 14% | ~10 |
   | 3 | 2024-03 | 39,568 | 12,447 | 31% | ~10 |
   | 4 | 2024-04 | 35,645 | 32,865 | 92% | ~25 |
   | 5 | 2024-05 | 40,906 | 14,879 | 36% | ~66 |

3. **429 vs Silent null**: With an API key, HTTP 429 rarely occurs. Instead, pagination terminates silently via `token: null`. Retry mechanisms (e.g., tenacity) that only handle 429 cannot detect this condition.

## C.3 Recommended Strategies for Large-Scale Collection

### 2-Pass Strategy

Requesting many fields in Bulk Search increases server load, causing earlier termination. Separating into two passes reduces per-stage load.

1. **Pass 1**: Request only `fields=paperId` to collect IDs (minimizes server load)
2. **Pass 2**: Use `POST /paper/batch` with 500 IDs per request for full field retrieval

### Delay Optimization

- **Pass 1 (Bulk Search)**: 0.5–1s recommended. Too short (0s) triggers 429 → retry backoff → cursor expiration. Too long (3s+) conserves budget but increases total elapsed time, risking server-side cursor expiration.
- **Pass 2 (Batch)**: 1–3s recommended. No cursor timeout pressure, but heavy usage depletes the budget for the next Pass 1 cycle.

### Time Partitioning

Splitting queries by month or finer granularity reduces each query's total result count, making it less susceptible to the pagination limit.

```python
# Monthly partitioning example
for year in range(2020, 2025):
    for month in range(1, 13):
        date_range = f"{year}-{month:02d}"
        params = {
            "query": "",
            "fields": "paperId",
            "fieldsOfStudy": "Biology",
            "publicationDateOrYear": date_range,
        }
        # ... bulk search pagination ...
```

### Detecting Early Pagination Termination

Compare the `total` field with the actual number of collected results to detect early termination. Save state for retry.

```python
if collected < reported_total:
    log.warning(
        "collected %d / %d (%.0f%%) — pagination limit hit",
        collected, reported_total, collected / reported_total * 100
    )
```

