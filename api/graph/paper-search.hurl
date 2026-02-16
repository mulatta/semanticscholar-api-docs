# Paper Relevance Search — search papers ranked by relevance
# Returns up to 1,000 results with offset/limit pagination.
# Usage: hurl --variable s2_api_key=KEY --variable query=transformer+attention api/graph/paper-search.hurl
GET https://api.semanticscholar.org/graph/v1/paper/search
x-api-key: {{s2_api_key}}
[QueryStringParams]
query: {{query}}
fields: title,year,citationCount
limit: 5
HTTP 200
[Asserts]
jsonpath "$.total" >= 0
jsonpath "$.data" count > 0
jsonpath "$.data[0].paperId" exists
jsonpath "$.data[0].title" exists
[Captures]
total: jsonpath "$.total"
result_count: jsonpath "$.data" count
first_paper_id: jsonpath "$.data[0].paperId"
first_title: jsonpath "$.data[0].title"
