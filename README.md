# Semantic Scholar API Guide

Bilingual (Korean / English) reference for the [Semantic Scholar Academic Graph API](https://api.semanticscholar.org/) (S2AG API v1), covering all 20 endpoints across papers, authors, citations, recommendations, and datasets.

## Contents

| #   | Section         | Endpoints | Description                                          |
| --- | --------------- | --------- | ---------------------------------------------------- |
| 1   | Overview        | —         | API structure, key concepts                          |
| 2   | Auth & Common   | —         | API keys, fields, pagination, IDs, filtering, errors |
| 3   | Paper Search    | 5         | Relevance, bulk, title match, autocomplete, snippet  |
| 4   | Paper Detail    | 5         | Single/batch lookup, citations, references, authors  |
| 5   | Author          | 4         | Search, detail, batch, papers by author              |
| 6   | Recommendations | 2         | Single/multi-paper recommendations                   |
| 7   | Datasets        | 4         | Dataset listing, release, links, diff                |
| 8   | Data Models     | —         | Full field reference for all response objects        |
| 9   | Appendix        | —         | Rate limits, changelog, migration notes              |

## Build

Requires [Nix](https://nixos.org/) with flakes enabled.

```bash
# Static site (Korean + English)
nix build .#site

# PDF per language
nix build .#pdf-ko
nix build .#pdf-en
```

Output is in `./result/`.

### Local preview

```bash
nix develop
zensical serve
```

## License

Documentation content is unofficial and community-maintained. Data provided by [Semantic Scholar](https://www.semanticscholar.org/) (Allen Institute for AI).
