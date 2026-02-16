---
title: "7. Datasets API"
description: "Full corpus download, release management, incremental updates (diffs)"
---

# 7. Datasets API

Base URL: `https://api.semanticscholar.org/datasets/v1`

Download the entire S2AG corpus or apply incremental updates from a previous release.

## 7.1 List Releases

Retrieve the list of available dataset releases.

```
GET /datasets/v1/release/
```

**Parameters:** None

**Response:**
```json
["2023-03-14", "2023-03-21", "2023-03-28"]
```

Release IDs are in date format (YYYY-MM-DD), and each release contains the full dataset.

#### Test with hurl

```bash
# List releases (no API key required)
hurl api/releases/list.hurl
```

## 7.2 Release Detail

Retrieve the list of datasets included in a specific release.

```
GET /datasets/v1/release/{release_id}
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `release_id` | path | string | Yes | Release ID (date) or `latest` |

**Response (Release Metadata):**
```json
{
  "release_id": "2023-03-28",
  "README": "Subject to the following terms ...",
  "datasets": [
    {
      "name": "abstracts",
      "description": "Paper abstract text, where available. 100M records in 30 1.8GB files.",
      "README": "This dataset contains ..."
    }
  ]
}
```

**Example:**
```bash
curl "https://api.semanticscholar.org/datasets/v1/release/latest"
```

#### Test with hurl

```bash
hurl --variable s2_api_key=$S2_API_KEY --variable release=2026-02-10 api/releases/detail.hurl
```

## 7.3 Dataset Download Links

Retrieve download URLs for a specific dataset in a specific release. Returns pre-signed URLs for files partitioned on S3.

```
GET /datasets/v1/release/{release_id}/dataset/{dataset_name}
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `release_id` | path | string | Yes | Release ID or `latest` |
| `dataset_name` | path | string | Yes | Dataset name (e.g., `abstracts`, `papers`) |

**Response (Dataset Metadata):**
```json
{
  "name": "abstracts",
  "description": "Paper abstract text, where available. 100M records in 30 1.8GB files.",
  "README": "Subject to terms of use as follows ...",
  "files": [
    "https://ai2-s2ag.s3.amazonaws.com/dev/staging/2023-03-28/abstracts/20230331_0..."
  ]
}
```

**Download example (Python):**
```python
import requests, json

meta = requests.get(
    "https://api.semanticscholar.org/datasets/v1/release/latest/dataset/abstracts"
).json()

for url in meta["files"]:
    # Download each partition file
    resp = requests.get(url, stream=True)
    # ...
```

#### Test with hurl

```bash
# Get download links for papers dataset
hurl --variable s2_api_key=$S2_API_KEY --variable release=2026-02-10 api/datasets/papers.hurl
```

All dataset-specific hurl files are under `api/datasets/`: `abstracts.hurl`, `authors.hurl`, `citations.hurl`, `embeddings-specter_v2.hurl`, `paper-ids.hurl`, `s2orc.hurl`, `s2orc_v2.hurl`, `tldrs.hurl`.

## 7.4 Incremental Diffs

Download only the changes from a previous release to a newer release. Update existing data without re-downloading everything.

```
GET /datasets/v1/diffs/{start_release_id}/to/{end_release_id}/{dataset_name}
```

**Parameters:**

| Name | Location | Type | Required | Description |
|---|---|---|---|---|
| `start_release_id` | path | string | Yes | Currently held release ID |
| `end_release_id` | path | string | Yes | Target release ID or `latest` |
| `dataset_name` | path | string | Yes | Dataset name |

**Response (Dataset Diff List):**
```json
{
  "dataset": "papers",
  "start_release": "2023-08-01",
  "end_release": "2023-08-29",
  "diffs": [
    {
      "from_release": "2023-08-01",
      "to_release": "2023-08-07",
      "update_files": ["https://..."],
      "delete_files": ["https://..."]
    }
  ]
}
```

Each diff represents changes between two consecutive releases:
- `update_files`: records to insert or update (upsert by primary key)
- `delete_files`: records to delete

**Application example (Python — DB/KV store):**
```python
import requests, json

difflist = requests.get(
    "https://api.semanticscholar.org/datasets/v1/diffs/2023-08-01/to/latest/papers"
).json()

for diff in difflist["diffs"]:
    for url in diff["update_files"]:
        for json_line in requests.get(url).iter_lines():
            record = json.loads(json_line)
            datastore.upsert(record["corpusid"], record)
    for url in diff["delete_files"]:
        for json_line in requests.get(url).iter_lines():
            record = json.loads(json_line)
            datastore.delete(record["corpusid"])
```

**Application example (PySpark):**
```python
current = sc.textFile("s3://curr-dataset").map(json.loads).keyBy(lambda x: x["corpusid"])
updates = sc.textFile("s3://diff-updates").map(json.loads).keyBy(lambda x: x["corpusid"])
deletes = sc.textFile("s3://diff-deletes").map(json.loads).keyBy(lambda x: x["corpusid"])

updated = current.fullOuterJoin(updates).mapValues(
    lambda x: x[1] if x[1] is not None else x[0]
)
updated = updated.fullOuterJoin(deletes).mapValues(
    lambda x: None if x[1] is not None else x[0]
).filter(lambda x: x[1] is not None)
updated.values().map(json.dumps).saveAsTextFile("s3://updated-dataset")
```

#### Test with hurl

```bash
# Get incremental diff for papers
hurl --variable s2_api_key=$S2_API_KEY --variable from=2026-02-03 --variable to=2026-02-10 api/diffs/papers.hurl
```

All dataset-specific hurl files are under `api/diffs/`: `abstracts.hurl`, `authors.hurl`, `citations.hurl`, `embeddings-specter_v2.hurl`, `paper-ids.hurl`, `tldrs.hurl`.

