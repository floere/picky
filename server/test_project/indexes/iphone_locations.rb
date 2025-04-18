require_relative '../models/iphone_data'
IphoneLocations = Picky::Index.new :iphone do
  key_format :to_i
  source { IphoneData.all('data/iphone_locations.csv') }
  ranged_category :timestamp, 86_400, precision: 5, qualifiers: %i[ts timestamp]
  geo_categories  :latitude, :longitude, 25, precision: 3
end
