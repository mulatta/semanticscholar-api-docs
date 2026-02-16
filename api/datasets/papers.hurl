# papers — core paper metadata (corpusid, title, year, etc.)
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/papers.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/papers
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "papers"
jsonpath "$.files" count > 0
[Captures]
papers_count: jsonpath "$.files" count
papers_url_0: jsonpath "$.files[0]"
