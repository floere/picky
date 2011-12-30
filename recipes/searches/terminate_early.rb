require File.expand_path '../../../server/lib/picky', __FILE__

Person = Struct.new :id, :first, :last

data = Picky::Index.new :people do
  category :first
  category :last
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'Worth')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data do
  boost [:first] => +1 # The first name category will be boosted.
  terminate_early # <= Only search for necessary allocations to get enough ids.
end

results = people.search 'niklaus', 1 # We just need one id, so just one allocation is enough.

# p results.allocations
fail __FILE__ unless results.ids == [2] # Only found in the first name category.