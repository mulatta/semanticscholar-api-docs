# citations — incremental diff
# Usage: hurl --variable s2_api_key=KEY --variable from=2026-02-03 --variable to=2026-02-10 api/diffs/citations.hurl
GET https://api.semanticscholar.org/datasets/v1/diffs/{{from}}/to/{{to}}/citations
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.dataset" == "citations"
jsonpath "$.diffs" count > 0
[Captures]
citations_updates: jsonpath "$.diffs[0].update_files" count
citations_deletes: jsonpath "$.diffs[0].delete_files" count
