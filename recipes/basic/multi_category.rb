require File.expand_path '../../../server/lib/picky', __FILE__

Person = Struct.new :id, :first, :last

# We want to search 2 indexes at once.
# One index uses a source, the indexes at realtime.
#
source = Picky::Index.new :people_from_source do
  source do
    [Person.new(1, 'Donald', 'Knuth'),
     Person.new(2, 'Niklaus', 'Wirth')]
  end
  category :first
  category :last
end
source.reindex

realtime = Picky::Index.new :people_with_realtime do
  category :first
  category :last
end
realtime.replace Person.new(3, 'Donald', 'Worth')
realtime.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new source, realtime # <= We pass the search both indexes.

results = people.search 'donald'

# p results.allocations
fail __FILE__ unless results.ids == [1, 3]
