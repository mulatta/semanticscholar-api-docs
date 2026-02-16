# Paper Autocomplete — fast autocompletion suggestions for interactive search
# Returns minimal info (id, title, authorsYear). Query truncated to 100 chars.
# Usage: hurl --variable s2_api_key=KEY --variable query=attention+is+all api/graph/paper-autocomplete.hurl
GET https://api.semanticscholar.org/graph/v1/paper/autocomplete
x-api-key: {{s2_api_key}}
[QueryStringParams]
query: {{query}}
HTTP 200
[Asserts]
jsonpath "$.matches" count > 0
jsonpath "$.matches[0].id" exists
jsonpath "$.matches[0].title" exists
[Captures]
match_count: jsonpath "$.matches" count
first_id: jsonpath "$.matches[0].id"
first_title: jsonpath "$.matches[0].title"
