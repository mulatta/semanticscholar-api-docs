# paper-batch — batch lookup of up to 500 papers in a single request
# Usage: hurl --variable s2_api_key=KEY --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b api/graph/paper-batch.hurl
POST https://api.semanticscholar.org/graph/v1/paper/batch
x-api-key: {{s2_api_key}}
Content-Type: application/json
[QueryStringParams]
fields: paperId,title,year
{
  "ids": ["{{paper_id}}"]
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].paperId" exists
jsonpath "$[0].title" exists
jsonpath "$[0].year" isInteger
[Captures]
batch_first_title: jsonpath "$[0].title"
