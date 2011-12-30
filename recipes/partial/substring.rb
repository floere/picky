require File.expand_path '../../../server/lib/picky', __FILE__

Person = Struct.new :id, :first, :last

data = Picky::Index.new :people do
  category :first
  
  # We add a full partial on the last name category.
  # Note that the to: -1 is not necessary, it is the default.
  #
  category :last, partial: Picky::Partial::Substring.new(from: 1, to: -1)
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'North')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data

results = people.search 'n' # <= Just looking for n will return partial results in category last but not Niklaus from category first.

# p results.allocations
fail __FILE__ unless results.ids == [4, 3]