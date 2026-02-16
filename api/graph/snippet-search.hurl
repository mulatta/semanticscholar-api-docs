# Snippet Search — full-text snippet search across paper bodies
# Returns ~500-word excerpts from paper text (excluding figures/references).
# Usage: hurl --variable s2_api_key=KEY --variable query=literature+graph+property+graph api/graph/snippet-search.hurl
GET https://api.semanticscholar.org/graph/v1/snippet/search
x-api-key: {{s2_api_key}}
[QueryStringParams]
query: {{query}}
limit: 3
HTTP 200
[Asserts]
jsonpath "$.data" count > 0
jsonpath "$.data[0].snippet.text" exists
jsonpath "$.data[0].snippet.snippetKind" exists
jsonpath "$.data[0].score" exists
jsonpath "$.data[0].paper" exists
[Captures]
result_count: jsonpath "$.data" count
first_snippet_text: jsonpath "$.data[0].snippet.text"
first_snippet_kind: jsonpath "$.data[0].snippet.snippetKind"
first_score: jsonpath "$.data[0].score"
