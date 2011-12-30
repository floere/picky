require File.expand_path '../../../server/lib/picky', __FILE__

TwoD = Struct.new :id, :x, :y

data = Picky::Index.new :coords do
  # 1.0 is the range around which to search
  # precision 1 is low precision (20% error margin), but fast
  #
  ranged_category :x, 1.0, precision: 1
  ranged_category :y, 1.0, precision: 1
end

data.replace TwoD.new(1, 3.2, 2.8)
data.replace TwoD.new(2, 1.8, 0.4)
data.replace TwoD.new(3, 9.7, 11.2)
data.replace TwoD.new(4, 4.1, 2.2)

two_d = Picky::Search.new data

# Since the x and y coordinates are not
# disjunct, we have to specify which is which.
#
results = two_d.search 'x:3.1 y:2.4'

# p results.allocations

# Picky just returns results in range, not ordered
# by distance. Usually that is fine for showing results
# in a graph or on a map.
#
fail __FILE__ unless results.ids == [4, 1]
