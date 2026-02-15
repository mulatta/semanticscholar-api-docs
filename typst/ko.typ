#import "template.typ": project, md

#show: project.with(
  title: "Semantic Scholar API 완전 가이드",
  subtitle: "S2AG API v1 한국어 레퍼런스",
  description: "S2AG API v1 — 논문, 저자, 인용, 추천, 데이터셋",
  lang: "ko",
  font-body: ("Apple SD Gothic Neo", "Noto Sans CJK KR"),
  font-mono: ("D2Coding", "Noto Sans CJK KR"),
)

#md("../docs/ko/00-index.md")
#md("../docs/ko/01-overview.md")
#md("../docs/ko/02-common.md")
#md("../docs/ko/03-paper-search.md")
#md("../docs/ko/04-paper-detail.md")
#md("../docs/ko/05-author.md")
#md("../docs/ko/06-recommendations.md")
#md("../docs/ko/07-datasets.md")
#md("../docs/ko/08-data-models.md")
#md("../docs/ko/09-appendix.md")
