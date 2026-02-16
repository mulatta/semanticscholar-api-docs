# Search authors by name
# Usage: hurl --variable s2_api_key=KEY --variable query=adam+smith api/graph/author-search.hurl
GET https://api.semanticscholar.org/graph/v1/author/search
x-api-key: {{s2_api_key}}
[QueryStringParams]
query: {{query}}
fields: name,affiliations,paperCount
limit: 5
HTTP 200
[Asserts]
jsonpath "$.total" exists
jsonpath "$.offset" exists
jsonpath "$.data" count > 0
jsonpath "$.data[0].authorId" exists
jsonpath "$.data[0].name" exists
[Captures]
total: jsonpath "$.total"
first_author_id: jsonpath "$.data[0].authorId"
first_author_name: jsonpath "$.data[0].name"
