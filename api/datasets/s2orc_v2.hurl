# s2orc_v2 — full-text from open-access PDFs (v2)
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/s2orc_v2.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/s2orc_v2
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "s2orc_v2"
jsonpath "$.files" count > 0
[Captures]
s2orc_v2_count: jsonpath "$.files" count
s2orc_v2_url_0: jsonpath "$.files[0]"
