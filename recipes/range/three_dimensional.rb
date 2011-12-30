require File.expand_path '../../../server/lib/picky', __FILE__

ThreeD = Struct.new :id, :x, :y, :z

data = Picky::Index.new :locations do
  # 1.0 is the range around which to search
  # precision 1 is low precision (20% error margin), but fast
  #
  ranged_category :x, 1.0, precision: 1
  ranged_category :y, 1.0, precision: 1
  ranged_category :z, 1.0, precision: 1
end

data.replace ThreeD.new(1, 3.2, 2.8, -8.5)
data.replace ThreeD.new(2, 1.8, 0.4, 13.7)
data.replace ThreeD.new(3, 9.7, 11.2, -7.0)
data.replace ThreeD.new(4, 4.1, 2.2, -7.5)

three_d = Picky::Search.new data

# Since the x, y and z coordinates are not
# disjunct, we have to specify which is which.
#
results = three_d.search 'x:3.1 y:2.4 z:-8.0'

# p results.allocations

# Picky just returns results in range, not ordered
# by distance. Usually that is fine for showing results
# in a graph or on a map.
#
fail __FILE__ unless results.ids == [4, 1]
