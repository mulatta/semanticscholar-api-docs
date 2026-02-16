# abstracts — paper abstract text
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/abstracts.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/abstracts
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "abstracts"
jsonpath "$.files" count > 0
[Captures]
abstracts_count: jsonpath "$.files" count
abstracts_url_0: jsonpath "$.files[0]"
