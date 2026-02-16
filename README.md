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

## API Testing

Executable [hurl](https://hurl.dev/) files for all 20 endpoints live under `api/`.

```
api/
├── graph/              # Academic Graph API (14 endpoints)
├── recommendations/    # Recommendations API (2 endpoints)
├── datasets/           # Dataset download links (9 dataset types)
├── diffs/              # Incremental diffs (7 dataset types)
└── releases/           # Release listing (2 endpoints)
```

### Run

```bash
nix develop  # provides hurl

# No API key required
hurl api/releases/list.hurl

# With API key
export S2_API_KEY=your-key-here
hurl --variable s2_api_key=$S2_API_KEY \
     --variable query=transformer \
     api/graph/paper-search.hurl

# Capture values as JSON
hurl --json --variable s2_api_key=$S2_API_KEY \
     --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b \
     api/graph/paper-detail.hurl

# Run all graph endpoints as tests (--jobs 1 to avoid 429)
hurl --test --jobs 1 --delay 1500 \
     --variable s2_api_key=$S2_API_KEY \
     --variable query=transformer \
     --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b \
     --variable author_id=1741101 \
     api/graph/*.hurl
```

### Variables

| Variable     | Used by                                              | Example                                    |
| ------------ | ---------------------------------------------------- | ------------------------------------------ |
| `s2_api_key` | all (except `releases/list.hurl`)                    | S2 API key                                 |
| `query`      | search endpoints                                     | `transformer`                              |
| `paper_id`   | paper detail/citations/refs/authors, recommendations | `649def34f8be52c8b66281af98ae884c09aef38b` |
| `author_id`  | author detail/batch/papers                           | `1741101`                                  |
| `release`    | datasets, releases/detail                            | `2026-02-10`                               |
| `from`, `to` | diffs                                                | `2026-02-03`, `2026-02-10`                 |

## License

Documentation content is unofficial and community-maintained. Data provided by [Semantic Scholar](https://www.semanticscholar.org/) (Allen Institute for AI).
