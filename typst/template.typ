// Pandoc typst template for S2 API Guide (Korean)

// Pandoc-required variable definitions
#let horizontalrule = line(length: 100%, stroke: 0.5pt + luma(200))

#set document(
  title: "Semantic Scholar API 완전 가이드",
  author: "S2AG API v1 한국어 레퍼런스",
)

#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: luma(120))
      [Semantic Scholar API 완전 가이드]
      h(1fr)
      [S2AG v1]
    }
  },
)

#set text(
  font: ("Apple SD Gothic Neo", "AppleGothic"),
  size: 10pt,
  lang: "ko",
)

#show raw: set text(
  font: ("D2Coding", "Apple SD Gothic Neo"),
  size: 8.5pt,
)

#show raw.where(block: true): block.with(
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(size: 18pt, weight: "bold")
  v(0.5cm)
  it
  v(0.3cm)
}

#show heading.where(level: 2): it => {
  set text(size: 13pt, weight: "bold")
  v(0.4cm)
  it
  v(0.2cm)
}

#show heading.where(level: 3): it => {
  set text(size: 11pt, weight: "bold")
  v(0.3cm)
  it
  v(0.1cm)
}

// Table styling: prevent overflow, allow word-break
#show table: set text(size: 9pt)
#set table(
  stroke: 0.5pt + luma(180),
  inset: (x: 6pt, y: 5pt),
)
#show table.cell: set par(justify: false, linebreaks: "optimized")
#show table.cell: set text(hyphenate: true)

#show link: it => {
  set text(fill: rgb("#1a56db"))
  it
}

// Title page
#align(center)[
  #v(4cm)
  #text(size: 28pt, weight: "bold")[Semantic Scholar API]
  #v(0.3cm)
  #text(size: 28pt, weight: "bold")[완전 가이드]
  #v(1cm)
  #text(size: 14pt, fill: luma(80))[S2AG API v1 — 논문, 저자, 인용, 추천, 데이터셋]
  #v(0.5cm)
  #text(size: 14pt, fill: luma(80))[한국어 레퍼런스]
  #v(2cm)
  #text(size: 10pt, fill: luma(120))[
    Academic Graph API · Recommendations API · Datasets API \
    20 Endpoints · 27+ Data Models
  ]
  #v(1cm)
  #line(length: 60%, stroke: 0.5pt + luma(180))
]

#pagebreak()

// Render pandoc body
$body$
