#import "template.typ": project, md

#show: project.with(
  title: "Semantic Scholar API Complete Guide",
  subtitle: "S2AG API v1 Reference",
  description: "S2AG API v1 — Papers, Authors, Citations, Recommendations, Datasets",
  lang: "en",
  font-body: ("New Computer Modern", "Noto Sans"),
  font-mono: ("D2Coding", "New Computer Modern Mono"),
)

#md("../docs/en/00-index.md")
#md("../docs/en/01-overview.md")
#md("../docs/en/02-common.md")
#md("../docs/en/03-paper-search.md")
#md("../docs/en/04-paper-detail.md")
#md("../docs/en/05-author.md")
#md("../docs/en/06-recommendations.md")
#md("../docs/en/07-datasets.md")
#md("../docs/en/08-data-models.md")
#md("../docs/en/09-appendix.md")
