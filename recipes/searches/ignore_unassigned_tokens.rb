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
  ignore_unassigned_tokens # <= Default is true, pass in true/false to be explicit.
end

# popeye cannot be assigned to a category,
# it will just be ignored.
#
results = people.search 'donald popeye knuth'

# p results.allocations
fail __FILE__ unless results.ids == [1]
