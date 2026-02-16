# List papers by a specific author
# Usage: hurl --variable s2_api_key=KEY --variable author_id=1741101 api/graph/author-papers.hurl
GET https://api.semanticscholar.org/graph/v1/author/{{author_id}}/papers
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: title,year,url,citationCount
limit: 10
HTTP 200
[Asserts]
jsonpath "$.offset" exists
jsonpath "$.data" count > 0
jsonpath "$.data[0].paperId" exists
jsonpath "$.data[0].title" exists
[Captures]
paper_count: jsonpath "$.data" count
first_paper_id: jsonpath "$.data[0].paperId"
first_paper_title: jsonpath "$.data[0].title"
