# paper-citations — list papers that cite a given paper
# Usage: hurl --variable s2_api_key=KEY --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b api/graph/paper-citations.hurl
GET https://api.semanticscholar.org/graph/v1/paper/{{paper_id}}/citations
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: contexts,intents,isInfluential,title
offset: 0
limit: 10
HTTP 200
[Asserts]
jsonpath "$.data" isCollection
jsonpath "$.data" count > 0
jsonpath "$.data[0].citingPaper.paperId" exists
[Captures]
citations_count: jsonpath "$.data" count
citing_paper_0: jsonpath "$.data[0].citingPaper.paperId"
