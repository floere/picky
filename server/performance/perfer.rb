# Run with:
#   perfer run perfer.rb
#
require_relative '../lib/picky'

data = Picky::Index.new :some_index do
  category :name
  category :surname
end
data.replace_from id: 1, name: 'florian', surname: 'hanke'
people = Picky::Search.new data

puts "Sanity check:"
puts people.search 'florian'
puts

Perfer.session "Search#search" do |s|
  s.metadata do
    description "Search for florian"
  end
  s.bench "Search#search('florian') with variable index size and fixed search size" do |n|
    data.clear
    
    n.times do |i|
      data.replace_from id: i, name: 'florian', surname: 'hanke'
    end
  
    s.measure { 1000.times { people.search 'florian' } }
  end
  # The following is pointless - the measurements grow with the number of searches.
  #
  # s.bench "Search#search('florian') with fixed index size but variable search size" do |n|
  #   1000.times do |i|
  #     data.replace_from id: i, name: 'florian', surname: 'hanke'
  #   end
  # 
  #   s.measure { n.times { people.search 'florian' } }
  # end
end
