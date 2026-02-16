# multi-paper — recommendations based on positive/negative paper sets
# Usage: hurl --variable s2_api_key=KEY api/recommendations/multi-paper.hurl
POST https://api.semanticscholar.org/recommendations/v1/papers/
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: title,year
limit: 5
Content-Type: application/json
{
  "positivePaperIds": ["649def34f8be52c8b66281af98ae884c09aef38b"],
  "negativePaperIds": ["ArXiv:1805.02262"]
}
HTTP 200
[Asserts]
jsonpath "$.recommendedPapers" isCollection
jsonpath "$.recommendedPapers" count > 0
jsonpath "$.recommendedPapers[0].paperId" isString
jsonpath "$.recommendedPapers[0].title" isString
[Captures]
rec_count: jsonpath "$.recommendedPapers" count
first_paper_id: jsonpath "$.recommendedPapers[0].paperId"
