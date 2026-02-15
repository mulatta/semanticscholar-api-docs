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

