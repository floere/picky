require File.expand_path '../../../server/lib/picky', __FILE__

GeoCoords = Struct.new :id, :lat, :lng

data = Picky::Index.new :people do
  # 1.0 is the radius in k around which to search.
  # precision 1 is low precision (20% error margin), but fast
  #
  geo_categories :lat, :lng, 1000.0 # 1000kms radius
end
cities = Picky::Search.new data

data.replace GeoCoords.new(1, -37.813611, 144.963056) # Melbourne
data.replace GeoCoords.new(2, -33.859972, 151.211111) # Sydney
data.replace GeoCoords.new(3, 47.366667, 8.55) # Zurich
data.replace GeoCoords.new(4, 41.9, 12.5) # Rome

# Picky just returns results in range, not ordered
# by distance. Usually that is fine for showing results
# in a graph or on a map.
#
fail __FILE__ unless cities.search('lat:-33.85 lng:150.2').ids == [2, 1]
