# single-paper — recommendations based on a single paper
# Usage: hurl --variable s2_api_key=KEY --variable paper_id=649def34f8be52c8b66281af98ae884c09aef38b api/recommendations/single-paper.hurl
GET https://api.semanticscholar.org/recommendations/v1/papers/forpaper/{{paper_id}}
x-api-key: {{s2_api_key}}
[QueryStringParams]
fields: title,year
limit: 5
from: recent
HTTP 200
[Asserts]
jsonpath "$.recommendedPapers" isCollection
jsonpath "$.recommendedPapers" count > 0
jsonpath "$.recommendedPapers[0].paperId" isString
jsonpath "$.recommendedPapers[0].title" isString
[Captures]
rec_count: jsonpath "$.recommendedPapers" count
first_paper_id: jsonpath "$.recommendedPapers[0].paperId"
