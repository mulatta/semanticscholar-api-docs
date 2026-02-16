# Paper Bulk Search — large-scale paper search with token-based pagination
# Supports boolean query syntax. Up to 1,000 results per call, 10M total via token paging.
# Usage: hurl --variable s2_api_key=KEY --variable query=transformer+attention api/graph/paper-bulk-search.hurl
GET https://api.semanticscholar.org/graph/v1/paper/search/bulk
x-api-key: {{s2_api_key}}
[QueryStringParams]
query: {{query}}
fields: title,year,citationCount
sort: citationCount:desc
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
token: jsonpath "$.token"
