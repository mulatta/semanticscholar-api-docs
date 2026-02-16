# s2orc — full-text from open-access PDFs (v1)
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/s2orc.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/s2orc
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "s2orc"
jsonpath "$.files" count > 0
[Captures]
s2orc_count: jsonpath "$.files" count
s2orc_url_0: jsonpath "$.files[0]"
