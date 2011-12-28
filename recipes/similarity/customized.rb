require File.expand_path '../../../server/lib/picky', __FILE__

# Our similarizer just encodes text as if
# it had just vowels. 
#
class Similarizer
  
  def encode text
    text.gsub /[^aeiou]/, ''
  end
  
  def prioritize(*)
    # We don't prioritize
  end
  
end

data = Picky::Index.new :people do
  category :first
  category :last, similarity: Similarizer.new # <= Pass in here.
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'Worth')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data

results = people.search 'iau~' # "Niklaus" becomes "iau".

# p results.allocations
fail __FILE__ unless results.ids == [4]
