---
title: "6. 추천 API"
description: "단일 논문 기반 추천, 다중 논문(positive/negative) 기반 추천"
type: chapter
chapter: 6
service: recommendations
base_url: https://api.semanticscholar.org/recommendations/v1
topics: [recommendations, single-paper, multi-paper, positive-negative]
endpoints:
  - method: GET
    path: /papers/forpaper/{paper_id}
    summary: 단일 논문 기반 추천
  - method: POST
    path: /papers/
    summary: 다중 논문 기반 추천
related: [05-author.md, 07-datasets.md, 08-data-models.md]
nav:
  prev: 05-author.md
  next: 07-datasets.md
  index: 00-index.md
---

# 6. 추천 API

Base URL: `https://api.semanticscholar.org/recommendations/v1`

## 6.1 단일 논문 기반 추천

하나의 논문을 기준으로 유사한 논문을 추천받는다.

```
GET /recommendations/v1/papers/forpaper/{paper_id}
```

**파라미터:**

| 이름 | 위치 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|---|
| `paper_id` | path | string | ✅ | | 기준 논문 ID |
| `limit` | query | integer | | 100 | 추천 수 (최대 500) |
| `fields` | query | string | | | 반환할 필드 목록 |
| `from` | query | string | | `recent` | 추천 풀: `recent` 또는 `all-cs` |

**추천 풀(from) 옵션:**

| 값 | 설명 |
|---|---|
| `recent` | 최근 논문 풀에서 추천 (기본값) |
| `all-cs` | 전체 CS 분야 논문 풀에서 추천 |

**예시:**
```bash
curl "https://api.semanticscholar.org/recommendations/v1/papers/forpaper/649def34f8be52c8b66281af98ae884c09aef38b?fields=title,year&limit=5&from=recent"
```

**응답:**
```json
{
  "recommendedPapers": [
    { "paperId": "...", "title": "...", "year": 2024 }
  ]
}
```

## 6.2 다중 논문 기반 추천 (Positive/Negative)

여러 논문을 positive(유사하게)/negative(회피하게) 예시로 제공하여 맞춤 추천을 받는다.

```
POST /recommendations/v1/papers/
```

**쿼리 파라미터:**

| 이름 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `limit` | integer | | 100 | 추천 수 (최대 500) |
| `fields` | string | | | 반환할 필드 목록 |

**요청 본문:**
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

- `positivePaperIds`: "이런 논문과 비슷한 것을 원해" — 추천의 기준
- `negativePaperIds`: "이런 논문은 원하지 않아" — 추천에서 배제할 방향

> **참고**: Swagger 스키마상 두 필드 모두 선택적(optional)이나, 실질적으로 `positivePaperIds`에 최소 1개 이상의 논문 ID가 필요하다.

> 다양한 ID 형식을 혼합 사용 가능 (S2 ID, ArXiv, DOI 등)

**응답:**
```json
{
  "recommendedPapers": [
    { "paperId": "...", "title": "...", "year": 2024 }
  ]
}
```

---
← [이전: 저자 API](05-author.md) | [목차](00-index.md) | [다음: 데이터셋 API →](07-datasets.md)
