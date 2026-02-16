# paper-detail — single paper lookup by ID (S2 hash, DOI:, ARXIV:, etc.)
# Usage: hurl --variable s2_api_key=KEY --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b api/graph/paper-detail.hurl
GET https://api.semanticscholar.org/graph/v1/paper/{{paper_id}}
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: paperId,title,year,citationCount,authors
HTTP 200
[Asserts]
jsonpath "$.paperId" exists
jsonpath "$.title" exists
jsonpath "$.year" isInteger
jsonpath "$.citationCount" >= 0
jsonpath "$.authors" count > 0
[Captures]
paper_title: jsonpath "$.title"
citation_count: jsonpath "$.citationCount"
