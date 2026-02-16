# embeddings-specter_v2 — 768-dim SPECTER2 vectors
# Usage: hurl --variable s2_api_key=KEY --variable release=2026-02-10 api/datasets/embeddings-specter_v2.hurl
GET https://api.semanticscholar.org/datasets/v1/release/{{release}}/dataset/embeddings-specter_v2
x-api-key: {{s2_api_key}}
HTTP 200
[Asserts]
jsonpath "$.name" == "embeddings-specter_v2"
jsonpath "$.files" count > 0
[Captures]
embeddings_count: jsonpath "$.files" count
embeddings_url_0: jsonpath "$.files[0]"
