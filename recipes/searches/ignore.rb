require File.expand_path '../../../server/lib/picky', __FILE__

data = Picky::Index.new :people do
  category :first
  category :last
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'Worth')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data do
  ignore :last # <= Give it a list of category (names) to ignore.
end

# niklaus will only be found in the first name,
# since any text that is assigned to the last
# name is ignored.
#
results = people.search 'niklaus'

# p results.allocations
fail __FILE__ unless results.ids == [2]
