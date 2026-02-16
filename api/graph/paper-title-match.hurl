# Paper Title Match — find the single best-matching paper by title
# Always returns 0 or 1 result with a matchScore. 404 if no match found.
# Usage: hurl --variable s2_api_key=KEY --variable query=Attention+Is+All+You+Need api/graph/paper-title-match.hurl
GET https://api.semanticscholar.org/graph/v1/paper/search/match
x-api-key: {{s2_api_key}}
[QueryStringParams]
query: {{query}}
fields: title,year,authors
HTTP 200
[Asserts]
jsonpath "$.data" count == 1
jsonpath "$.data[0].paperId" exists
jsonpath "$.data[0].title" exists
jsonpath "$.data[0].matchScore" exists
[Captures]
paper_id: jsonpath "$.data[0].paperId"
title: jsonpath "$.data[0].title"
match_score: jsonpath "$.data[0].matchScore"
