require 'picky'

data = Picky::Index.new :models do
  category :id
  category :name
  category :surname
end

data.replace_from id: 1, name: 'Picky', surname: 'McNamara'
data.replace_from id: 2, name: 'Florian', surname: 'Hanke'
data.replace_from id: 3, name: 'Tentacles', surname: 'Jellyfish'
data.replace_from id: 4, name: 'Tentacles', surname: 'Florian'
data.replace_from id: 5, name: 'Florian', surname: 'Tentacles'

# Look facets up in the index.
#
puts "Facets:"
puts data[:name].exact.inverted.inject({}) { |result, token_ids|
  token, ids = token_ids
  result[token] = ids.size
  result
}


class Picky::Index
  
  def facets(category)
    self[category].exact.inverted.inject({}) { |result, token_ids|
      token, ids = token_ids
      result[token] = ids.size
      result
    }
  end
  
end

puts data.facets :name
puts data.facets :surname

# Query generation.
#
puts "Queries: (with original query 'something')"
queries = data.facets(:name).map do |token, _|
  "name:#{token} something"
end
puts queries