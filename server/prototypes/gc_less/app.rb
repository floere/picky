require_relative '../../lib/picky'

def count klass
  "#{klass}: #{ObjectSpace.each_object(klass).inject(0) { |total, _| total = total + 1 }}"
end
def counts
  puts count(Picky::Query::Allocation)
  puts count(Picky::Query::Allocations)
  puts count(Picky::Query::Combination)
  puts count(Picky::Query::Combinations)
  puts count(Picky::Query::Token)
  puts count(Picky::Query::Tokens)
end

data = Picky::Index.new :models do
  category :id
  category :name
  category :surname
end

data.replace_from id: 1, name: 'Picky', surname: 'McNamara'
data.replace_from id: 2, name: 'Florian', surname: 'Hanke'
data.replace_from id: 3, name: 'Tentacles', surname: 'Jellyfish'
data.replace_from id: 4, name: 'Tentacles', surname: 'Florian'
data.replace_from id: 5, name: 'Florian', surname: 'Tentacles'

people = Picky::Search.new data
counts

puts people.search 'hanke', 20, 0
counts

puts people.search 'tentacles florian', 20, 0
counts

puts people.search 'tentacles florian', 20, 0
counts

puts people.search 'tentacles florian tentacles', 20, 0
counts

require 'benchmark'
puts Benchmark.measure {
  1000.times { people.search 'tentacles florian tentacles', 20, 0 }
}