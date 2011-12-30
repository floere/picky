require File.expand_path '../../../server/lib/picky', __FILE__

OneD = Struct.new :id, :value

data = Picky::Index.new :values do
  # 1.0 is the range around which to search
  # precision 1 is low precision (20% error margin), but fast
  #
  ranged_category :value, 1.0, precision: 1
end

data.replace OneD.new(1, 3.2)
data.replace OneD.new(2, 1.8)
data.replace OneD.new(3, 9.7)
data.replace OneD.new(4, 4.1)

one_d = Picky::Search.new data

results = one_d.search '3.1'

# p results.allocations

# Picky just returns results in range, not ordered
# by distance. Usually that is fine for showing results
# in a graph or on a map.
#
fail __FILE__ unless results.ids == [4, 1]
