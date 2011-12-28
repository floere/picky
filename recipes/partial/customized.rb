require File.expand_path '../../../server/lib/picky', __FILE__

# Our special partializer only allows partials
# of even length.
#
class Partializer
  
  def each_partial text
    temp = text.dup
    temp.length.times do
      yield temp if temp.size.even?
      temp.chop!
    end
  end
  
end

data = Picky::Index.new :people do
  category :first  
  category :last, partial: Partializer.new # <= Passed in here.
end

data.replace Person.new(1, 'Donald', 'Knuth')
data.replace Person.new(2, 'Niklaus', 'Wirth')
data.replace Person.new(3, 'Donald', 'North')
data.replace Person.new(4, 'Peter', 'Niklaus')

people = Picky::Search.new data

# Finds only even partials.
#
fail __FILE__ unless people.search('n').ids == []
fail __FILE__ unless people.search('no').ids == [3]
fail __FILE__ unless people.search('nor').ids == []
fail __FILE__ unless people.search('nort').ids == [3]