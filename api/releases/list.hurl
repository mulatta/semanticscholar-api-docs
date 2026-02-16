# List all available releases
# Usage: hurl api/releases/list.hurl
GET https://api.semanticscholar.org/datasets/v1/release/
HTTP 200
[Asserts]
jsonpath "$" count > 0
[Captures]
latest_release: jsonpath "$[-1:]" nth 0
