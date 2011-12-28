require File.expand_path '../../server/lib/picky', __FILE__

data = Picky::Index.new :people do
  source do
    [Person.new(1, 'Donald', 'Knuth'),
     Person.new(2, 'Niklaus', 'Wirth'),
     Person.new(3, 'Donald', 'Worth'),
     Person.new(4, 'Peter', 'Niklaus')]
  end
  category :first
  category :last
end

people = Picky::Search.new data

data.reindex # aka data.index; data.load

results = people.search 'donald'

# p results.allocations
fail __FILE__ unless results.ids == [1, 3]