offsets = [0, 20]
queries = %w|t te tes test testi tests|
ids     = [0, 20]

10_000.times do
  offset = offsets[rand(offsets.size)]
  query  = queries[rand(queries.size)]
  id     = ids[rand(ids.size)]
  `curl 'localhost:8080/books?query=#{query}&offset=#{offset}&ids=#{id}'`
end