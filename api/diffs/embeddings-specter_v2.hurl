# embeddings-specter_v2 — incremental diff
# Usage: hurl --variable s2_api_key=KEY --variable from=2026-02-03 --variable to=2026-02-10 api/diffs/embeddings-specter_v2.hurl
GET https://api.semanticscholar.org/datasets/v1/diffs/{{from}}/to/{{to}}/embeddings-specter_v2
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.dataset" == "embeddings-specter_v2"
jsonpath "$.diffs" count > 0
[Captures]
embeddings_updates: jsonpath "$.diffs[0].update_files" count
embeddings_deletes: jsonpath "$.diffs[0].delete_files" count
