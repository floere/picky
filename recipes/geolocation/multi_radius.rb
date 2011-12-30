require File.expand_path '../../../server/lib/picky', __FILE__

GeoCoords = Struct.new :id, :lat, :lng

data = Picky::Index.new :cities do
  # 1.0 is the radius in k around which to search.
  # precision 1 is low precision (20% error margin), but fast
  #
  geo_categories :lat1,    :lng1,       1.0, :lat_from => :lat, :lng_from => :lng
  geo_categories :lat10,   :lng10,     10.0, :lat_from => :lat, :lng_from => :lng
  geo_categories :lat100,  :lng100,   100.0, :lat_from => :lat, :lng_from => :lng
  geo_categories :lat1000, :lng1000, 1000.0, :lat_from => :lat, :lng_from => :lng
end

data.replace GeoCoords.new(1, -37.813611, 144.963056) # Melbourne
data.replace GeoCoords.new(2, -33.859972, 151.211111) # Sydney
data.replace GeoCoords.new(3, 47.366667, 8.55) # Zurich
data.replace GeoCoords.new(4, 41.9, 12.5) # Rome

cities = Picky::Search.new data

# Picky just returns results in range, not ordered
# by distance. Usually that is fine for showing results
# in a graph or on a map.
#
fail __FILE__ unless cities.search('lat1:-33.85 lng1:150.2').ids == []
fail __FILE__ unless cities.search('lat10:-33.85 lng10:150.2').ids == []
fail __FILE__ unless cities.search('lat100:-33.85 lng100:150.2').ids == [2]
fail __FILE__ unless cities.search('lat1000:-33.85 lng1000:150.2').ids == [2, 1]