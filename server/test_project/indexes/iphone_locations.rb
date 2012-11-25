require_relative '../models/iphone_data'
IphoneLocations = Picky::Index.new :iphone do
  source { IphoneData.all('data/iphone_locations.csv') }
  ranged_category :timestamp, 86_400, precision: 5, qualifiers: [:ts, :timestamp]
  geo_categories  :latitude, :longitude, 25, precision: 3
end