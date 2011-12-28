require File.expand_path '../../../server/lib/picky', __FILE__

data = Picky::Index.new :people do
  category :first
  
  # We search only for pieces that are of length 1 to 3
  # in the last name.
  #
  category :last, partial: Picky::Partial::Infix.new(min: 1, max:3)
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'North')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data

results = people.search 'n' # <= Just looking for n will return partial results from 4, 3, 1, since n is in these last names.

# p results.allocations
fail __FILE__ unless results.ids == [4, 3, 1]
