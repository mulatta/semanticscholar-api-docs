# citations — citing/cited pairs with context and intent
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/citations.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/citations
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "citations"
jsonpath "$.files" count > 0
[Captures]
citations_count: jsonpath "$.files" count
citations_url_0: jsonpath "$.files[0]"
