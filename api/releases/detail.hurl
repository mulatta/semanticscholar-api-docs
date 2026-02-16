# Get release details (dataset listing without file URLs)
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/releases/detail.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.release_id" == {{release}}
jsonpath "$.datasets" count > 0
