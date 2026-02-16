# authors — author metadata
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/authors.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/authors
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "authors"
jsonpath "$.files" count > 0
[Captures]
authors_count: jsonpath "$.files" count
authors_url_0: jsonpath "$.files[0]"
