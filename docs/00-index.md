---
title: Semantic Scholar API 완전 가이드
description: S2AG API v1 한국어 레퍼런스 — 목차 및 네비게이션
type: index
api_version: v1
base_urls:
  graph: https://api.semanticscholar.org/graph/v1
  recommendations: https://api.semanticscholar.org/recommendations/v1
  datasets: https://api.semanticscholar.org/datasets/v1
total_endpoints: 20
source_files:
  - ../s2-graph-api.json
  - ../s2-recommendations-api.json
  - ../s2-datasets-api.json
---

# Semantic Scholar API 완전 가이드

> S2AG API v1 — 논문, 저자, 인용, 추천, 데이터셋까지 전체 엔드포인트를 다루는 한국어 레퍼런스

---

## 가이드 구조

| # | 파일 | 제목 | EP | 내용 요약 |
|---|------|------|----|-----------|
| 1 | `01-overview` | 개요 | — | API 구성, 주요 개념 |
| 2 | `02-common` | 인증/공통 | — | API 키, fields, 페이지네이션, ID, 필터, 에러 |
| 3 | `03-paper-search` | 논문 검색 | 5 | relevance, bulk, title match, autocomplete, snippet |
| 4 | `04-paper-detail` | 논문 상세 | 5 | 단일/배치 조회, 인용/참조/저자 |
| 5 | `05-author` | 저자 | 4 | 검색, 상세, 배치, 저자별 논문 |
| 6 | `06-recommendations` | 추천 | 2 | 단일/다중 논문 기반 추천 |
| 7 | `07-datasets` | 데이터셋 | 4 | 릴리스, 다운로드, 증분 diff |
| 8 | `08-data-models` | 모델 레퍼런스 | — | 14개 모델 + 래퍼 + 특수 변형 |
| 9 | `09-appendix` | 부록 | — | 요약표, 실전 패턴 6개 |

---

## 빠른 참조

### 엔드포인트 → 파일 매핑

| 엔드포인트 | 메서드 | 파일 |
|-----------|--------|------|
| `/paper/search` | GET | [03-paper-search.md](03-paper-search.md#31-paper-relevance-search) |
| `/paper/search/bulk` | GET | [03-paper-search.md](03-paper-search.md#32-paper-bulk-search) |
| `/paper/search/match` | GET | [03-paper-search.md](03-paper-search.md#33-paper-title-match) |
| `/paper/autocomplete` | GET | [03-paper-search.md](03-paper-search.md#34-paper-autocomplete) |
| `/snippet/search` | GET | [03-paper-search.md](03-paper-search.md#35-snippet-search) |
| `/paper/{paper_id}` | GET | [04-paper-detail.md](04-paper-detail.md#41-논문-단일-조회) |
| `/paper/batch` | POST | [04-paper-detail.md](04-paper-detail.md#42-논문-배치-조회) |
| `/paper/{id}/citations` | GET | [04-paper-detail.md](04-paper-detail.md#43-논문의-인용-목록-citations) |
| `/paper/{id}/references` | GET | [04-paper-detail.md](04-paper-detail.md#44-논문의-참조-목록-references) |
| `/paper/{id}/authors` | GET | [04-paper-detail.md](04-paper-detail.md#45-논문의-저자-목록) |
| `/author/search` | GET | [05-author.md](05-author.md#51-저자-검색) |
| `/author/{author_id}` | GET | [05-author.md](05-author.md#52-저자-상세-조회) |
| `/author/batch` | POST | [05-author.md](05-author.md#53-저자-배치-조회) |
| `/author/{id}/papers` | GET | [05-author.md](05-author.md#54-저자의-논문-목록) |
| `/papers/forpaper/{id}` | GET | [06-recommendations.md](06-recommendations.md#61-단일-논문-기반-추천) |
| `/papers/` | POST | [06-recommendations.md](06-recommendations.md#62-다중-논문-기반-추천-positivenegative) |
| `/release/` | GET | [07-datasets.md](07-datasets.md#71-릴리스-목록-조회) |
| `/release/{id}` | GET | [07-datasets.md](07-datasets.md#72-릴리스-상세-조회) |
| `/release/{id}/dataset/{name}` | GET | [07-datasets.md](07-datasets.md#73-데이터셋-다운로드-링크) |
| `/diffs/{start}/to/{end}/{name}` | GET | [07-datasets.md](07-datasets.md#74-증분-업데이트-incremental-diffs) |

### 데이터 모델 → 파일 매핑

| 모델 | 설명 | 참조 |
|------|------|------|
| `BasePaper` | 논문 기본 모델 (22 필드) | [08-data-models.md § 8.1](08-data-models.md#81-paper-basepaper) |
| `FullPaper` | BasePaper + embedding/tldr/citations/references | [08-data-models.md § 8.2](08-data-models.md#82-fullpaper-단일-논문-조회-전용-추가-필드) |
| `Author` | 저자 상세 모델 | [08-data-models.md § 8.3](08-data-models.md#83-author) |
| `Citation` / `Reference` | 인용/참조 관계 모델 | [08-data-models.md § 8.5–8.6](08-data-models.md#85-citation) |
| 응답 래퍼 (4 패턴) | offset / offset+total / token / 단순 | [08-data-models.md § 8.13](08-data-models.md#813-응답-래퍼-모델-response-wrappers) |
| 특수 변형 모델 | Title Match, Autocomplete, PaperInfo 등 | [08-data-models.md § 8.14](08-data-models.md#814-특수-변형-모델) |
