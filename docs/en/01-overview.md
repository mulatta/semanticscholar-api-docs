---
title: "1. Overview"
description: "Semantic Scholar API structure and key concepts"
---

# 1. Overview

Semantic Scholar API is a public API for the academic paper search platform operated by the Allen Institute for AI. It provides programmatic access to metadata, citation relationships, and author information for over 200 million papers.

## 1.1 API Structure

The API consists of three independent services:

| Service | Base URL | Endpoints | Purpose |
|---------|----------|-----------|---------|
| **Academic Graph API** | `https://api.semanticscholar.org/graph/v1` | 14 | Paper/author search, lookup, citation relationships |
| **Recommendations API** | `https://api.semanticscholar.org/recommendations/v1` | 2 | Paper recommendations |
| **Datasets API** | `https://api.semanticscholar.org/datasets/v1` | 4 | Full corpus download, incremental updates |

## 1.2 Key Concepts

- **paperId**: S2's primary paper identifier (SHA hash string)
- **corpusId**: S2's secondary paper identifier (int64, primarily used in datasets)
- **fields parameter**: Specifies which fields to include in the response. If omitted, only minimal fields are returned.
- **External ID support**: Papers can also be looked up using external identifiers such as DOI, ArXiv, PubMed, ACL, DBLP, MAG, etc.

