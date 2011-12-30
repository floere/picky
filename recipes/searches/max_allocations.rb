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
  boost [:first] => +1 # First name will be better than the last name.
  max_allocations 1 # <= Only search for the first (best) allocation.
end

# The niklaus in the first name will be found
# and the one in the last name will be thrown
# away.
#
results = people.search 'niklaus'

# p results.allocations
fail __FILE__ unless results.ids == [2]
