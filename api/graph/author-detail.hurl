# Get single author details by ID
# Usage: hurl --variable s2_api_key=KEY --variable author_id=1741101 api/graph/author-detail.hurl
GET https://api.semanticscholar.org/graph/v1/author/{{author_id}}
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: name,url,affiliations,paperCount,citationCount,hIndex
HTTP 200
[Asserts]
jsonpath "$.authorId" exists
jsonpath "$.name" exists
jsonpath "$.url" exists
jsonpath "$.paperCount" exists
[Captures]
author_id: jsonpath "$.authorId"
author_name: jsonpath "$.name"
paper_count: jsonpath "$.paperCount"
h_index: jsonpath "$.hIndex"
