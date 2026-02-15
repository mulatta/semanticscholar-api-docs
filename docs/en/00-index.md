---
title: Semantic Scholar API Complete Guide
description: "S2AG API v1 Reference — Table of Contents"
---

# Semantic Scholar API Complete Guide

> S2AG API v1 — A comprehensive reference covering all endpoints for papers, authors, citations, recommendations, and datasets.

---

## Guide Structure

| # | File | Title | EP | Summary |
|---|------|-------|----|---------|
| 1 | `01-overview` | Overview | — | API structure, key concepts |
| 2 | `02-common` | Auth & Common | — | API key, fields, pagination, IDs, filters, errors |
| 3 | `03-paper-search` | Paper Search | 5 | relevance, bulk, title match, autocomplete, snippet |
| 4 | `04-paper-detail` | Paper Detail | 5 | single/batch lookup, citations/references/authors |
| 5 | `05-author` | Author | 4 | search, detail, batch, papers by author |
| 6 | `06-recommendations` | Recommendations | 2 | single/multi-paper recommendations |
| 7 | `07-datasets` | Datasets | 4 | releases, downloads, incremental diffs |
| 8 | `08-data-models` | Model Reference | — | 14 models + wrappers + special variants |
| 9 | `09-appendix` | Appendix | — | summary table, 6 practical patterns |

---

## Quick Reference

### Endpoint → File Mapping

| Endpoint | Method | File |
|----------|--------|------|
| `/paper/search` | GET | [03-paper-search.md](03-paper-search.md#31-paper-relevance-search) |
| `/paper/search/bulk` | GET | [03-paper-search.md](03-paper-search.md#32-paper-bulk-search) |
| `/paper/search/match` | GET | [03-paper-search.md](03-paper-search.md#33-paper-title-match) |
| `/paper/autocomplete` | GET | [03-paper-search.md](03-paper-search.md#34-paper-autocomplete) |
| `/snippet/search` | GET | [03-paper-search.md](03-paper-search.md#35-snippet-search) |
| `/paper/{paper_id}` | GET | [04-paper-detail.md](04-paper-detail.md#41-single-paper-lookup) |
| `/paper/batch` | POST | [04-paper-detail.md](04-paper-detail.md#42-paper-batch-lookup) |
| `/paper/{id}/citations` | GET | [04-paper-detail.md](04-paper-detail.md#43-paper-citations) |
| `/paper/{id}/references` | GET | [04-paper-detail.md](04-paper-detail.md#44-paper-references) |
| `/paper/{id}/authors` | GET | [04-paper-detail.md](04-paper-detail.md#45-paper-authors) |
| `/author/search` | GET | [05-author.md](05-author.md#51-author-search) |
| `/author/{author_id}` | GET | [05-author.md](05-author.md#52-author-detail) |
| `/author/batch` | POST | [05-author.md](05-author.md#53-author-batch-lookup) |
| `/author/{id}/papers` | GET | [05-author.md](05-author.md#54-author-papers) |
| `/papers/forpaper/{id}` | GET | [06-recommendations.md](06-recommendations.md#61-single-paper-recommendations) |
| `/papers/` | POST | [06-recommendations.md](06-recommendations.md#62-multi-paper-recommendations-positivenegative) |
| `/release/` | GET | [07-datasets.md](07-datasets.md#71-list-releases) |
| `/release/{id}` | GET | [07-datasets.md](07-datasets.md#72-release-detail) |
| `/release/{id}/dataset/{name}` | GET | [07-datasets.md](07-datasets.md#73-dataset-download-links) |
| `/diffs/{start}/to/{end}/{name}` | GET | [07-datasets.md](07-datasets.md#74-incremental-diffs) |

### Data Model → File Mapping

| Model | Description | Reference |
|-------|-------------|-----------|
| `BasePaper` | Base paper model (22 fields) | [08-data-models.md § 8.1](08-data-models.md#81-paper-basepaper) |
| `FullPaper` | BasePaper + embedding/tldr/citations/references | [08-data-models.md § 8.2](08-data-models.md#82-fullpaper-additional-fields-for-single-paper-lookup) |
| `Author` | Author detail model | [08-data-models.md § 8.3](08-data-models.md#83-author) |
| `Citation` / `Reference` | Citation/reference relationship models | [08-data-models.md § 8.5–8.6](08-data-models.md#85-citation) |
| Response Wrappers (4 patterns) | offset / offset+total / token / simple | [08-data-models.md § 8.13](08-data-models.md#813-response-wrappers) |
| Special Variant Models | Title Match, Autocomplete, PaperInfo, etc. | [08-data-models.md § 8.14](08-data-models.md#814-special-variant-models) |
