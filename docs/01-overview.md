---
title: "1. 개요"
description: "Semantic Scholar API 구성 및 주요 개념"
type: chapter
chapter: 1
topics: [api-structure, services, key-concepts]
related: [02-common.md]
nav:
  prev: null
  next: 02-common.md
  index: 00-index.md
---

# 1. 개요

Semantic Scholar API는 Allen Institute for AI가 운영하는 학술 논문 검색 플랫폼의 공개 API다. 2억 건 이상의 논문 메타데이터, 인용 관계, 저자 정보를 프로그래밍 방식으로 조회할 수 있다.

## 1.1 API 구성

3개의 독립적인 서비스로 구성된다:

| 서비스 | Base URL | 엔드포인트 수 | 용도 |
|---|---|---|---|
| **Academic Graph API** | `https://api.semanticscholar.org/graph/v1` | 14 | 논문/저자 검색·조회·인용 관계 |
| **Recommendations API** | `https://api.semanticscholar.org/recommendations/v1` | 2 | 논문 추천 |
| **Datasets API** | `https://api.semanticscholar.org/datasets/v1` | 4 | 전체 코퍼스 다운로드·증분 업데이트 |

## 1.2 주요 개념

- **paperId**: S2의 기본 논문 식별자 (SHA 해시 문자열)
- **corpusId**: S2의 보조 논문 식별자 (int64, 데이터셋에서 주로 사용)
- **fields 파라미터**: 응답에 포함할 필드를 지정. 지정하지 않으면 최소 필드만 반환됨
- **외부 ID 지원**: DOI, ArXiv, PubMed, ACL, DBLP, MAG 등의 외부 식별자로도 논문 조회 가능

---
← [목차](00-index.md) | [다음: 인증 및 공통사항 →](02-common.md)
