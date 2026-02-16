# paper-authors — list authors of a given paper
# Usage: hurl --variable s2_api_key=KEY --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b api/graph/paper-authors.hurl
GET https://api.semanticscholar.org/graph/v1/paper/{{paper_id}}/authors
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: name,affiliations,paperCount,citationCount
offset: 0
limit: 100
HTTP 200
[Asserts]
jsonpath "$.data" isCollection
jsonpath "$.data" count > 0
jsonpath "$.data[0].authorId" exists
jsonpath "$.data[0].name" exists
[Captures]
authors_count: jsonpath "$.data" count
author_0_name: jsonpath "$.data[0].name"
