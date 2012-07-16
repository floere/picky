require_relative '../../lib/picky'

data = Picky::Index.new :models do
  category :id
  category :name
  category :surname
end

data.replace_from id: 1, name: 'Picky', surname: 'McNamara'
data.replace_from id: 2, name: 'Florian', surname: 'Hanke'
data.replace_from id: 3, name: 'Tentacles', surname: 'Jellyfish'

people = Picky::Search.new data

p ObjectSpace.each_object(Picky::Query::Allocation).inject(0) { |total, _| total = total + 1 }

results = people.search 'hanke', 20, 0

p ObjectSpace.each_object(Picky::Query::Allocation).inject(0) { |total, _| total = total + 1 }

results = people.search 'hanke', 20, 0
results = people.search 'hanke', 20, 0

p ObjectSpace.each_object(Picky::Query::Allocation).inject(0) { |total, _| total = total + 1 }