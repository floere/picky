require File.expand_path '../../../server/lib/picky', __FILE__

# Our customized weighter for the last name.
# We weigh results higher that are only found once.
#
class Weighter
  
  def weight_for ids_size
    ids_size > 1 ? -1.0 : +10.0
  end
  
end

data = Picky::Index.new :people do
  category :first
  category :last, weight: Weighter.new # <= Pass in here.
end

data.replace Person.new(1, 'Niklaus', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'Wirth')
data.replace Person.new(4, 'Peter', 'Niklaus') # <= Only found once in last name.

people = Picky::Search.new data

results = people.search 'niklaus'

# p results.allocations
fail __FILE__ unless results.ids == [4, 2, 1] # The last name "Niklaus" is preferred. It occurs twice in the first name.
