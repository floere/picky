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
  boost [:last] => +3 # <= We boost a combination of just last name with +3
end

results = people.search 'niklaus'

# p results.allocations
fail __FILE__ unless results.ids == [4, 2]
