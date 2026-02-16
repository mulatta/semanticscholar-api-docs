# tldrs — AI-generated paper summaries
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/tldrs.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/tldrs
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "tldrs"
jsonpath "$.files" count > 0
[Captures]
tldrs_count: jsonpath "$.files" count
tldrs_url_0: jsonpath "$.files[0]"
