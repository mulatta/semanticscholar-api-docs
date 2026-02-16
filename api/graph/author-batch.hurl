# Batch lookup multiple authors by IDs
# Usage: hurl --variable s2_api_key=KEY --variable author_id=1741101 api/graph/author-batch.hurl
POST https://api.semanticscholar.org/graph/v1/author/batch
x-api-key: {{s2_api_key}}
Content-Type: application/json
[QueryStringParams]
fields: name,url,affiliations,paperCount,hIndex
{
  "ids": ["{{author_id}}"]
}
HTTP 200
[Asserts]
jsonpath "$" count > 0
jsonpath "$[0].authorId" exists
jsonpath "$[0].name" exists
[Captures]
first_author_id: jsonpath "$[0].authorId"
first_author_name: jsonpath "$[0].name"
