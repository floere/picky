require File.expand_path '../../../server/lib/picky', __FILE__

data = Picky::Index.new :people do
  category :first
  category :last
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'Worth')
data.replace Person.new(4, 'Peter', 'Niklaus')

# We're creating a specific booster
# that responds to the boost_for(combinations)
# method and returns a float to boost
# specific combinations.
#
class Booster 
  @@mapping = {
    [:last] => +1,
    [:some, :other, :ordered, :combination] => -4
  }
  
  def boost_for combinations
    @@mapping[combinations.map(&:category_name)] || 0
  end
end

people = Picky::Search.new data do
  boost Booster.new
end

results = people.search 'niklaus'

# p results.allocations
fail __FILE__ unless results.ids == [4, 2]
