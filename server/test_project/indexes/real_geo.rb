require_relative '../models/swiss_locations'
RealGeoIndex = Picky::Index.new :real_geo do
  source         { SwissLocations.all('data/ch.csv', col_sep: ",") }
  category       :location, partial: Picky::Partial::Substring.new(from: 1)
  geo_categories :north, :east, 1, precision: 3
end