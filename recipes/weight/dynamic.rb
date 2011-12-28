require File.expand_path '../../../server/lib/picky', __FILE__

data = Picky::Index.new :people do
  category :first
  
  # With a dynamic weight you get the query token text.
  #
  # This one penalizes finds on the last name on odd length search texts.
  # (Yes, it does not make a lot of sense ;) )
  #
  category :last, weight: Picky::Weights::Dynamic.new { |text| text.size.even? ? 3.0 : -1.0 }
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'Worth')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data

results = people.search 'niklaus'

# p results.allocations
fail __FILE__ unless results.ids == [2, 4] # Last name is penalized since "niklaus" is of odd length.
