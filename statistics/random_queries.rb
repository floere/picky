100.times do
  offsets = [0, 20, 0, 20, 20, 0, 0, 20, 20, 20, 20, 0, 0, 0, 0]
  queries = %w|t te tes test testi tests|
  ids     = [0, 0, 20, 20]

  offsets = offsets[rand(offsets.size)-4, 4]
  queries = queries[rand(queries.size)-3, 3]
  ids     = ids[rand(ids.size)-2, 2]

  100.times do
    offset = offsets[rand(offsets.size)]
    query  = queries[rand(queries.size)]
    id     = ids[rand(ids.size)]
    `curl 'localhost:8080/books?query=#{query}&offset=#{offset}&ids=#{id}'`
  end
end