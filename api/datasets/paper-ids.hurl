# paper-ids — sha to corpusId mapping
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/paper-ids.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/paper-ids
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "paper-ids"
jsonpath "$.files" count > 0
[Captures]
paper_ids_count: jsonpath "$.files" count
paper_ids_url_0: jsonpath "$.files[0]"
