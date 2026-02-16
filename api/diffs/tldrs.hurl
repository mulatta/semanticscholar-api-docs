# tldrs — incremental diff
# Usage: hurl --variable s2_api_key=KEY --variable from=2026-02-03 --variable to=2026-02-10 api/diffs/tldrs.hurl
GET https://api.semanticscholar.org/datasets/v1/diffs/{{from}}/to/{{to}}/tldrs
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.dataset" == "tldrs"
jsonpath "$.diffs" count > 0
[Captures]
tldrs_updates: jsonpath "$.diffs[0].update_files" count
tldrs_deletes: jsonpath "$.diffs[0].delete_files" count
