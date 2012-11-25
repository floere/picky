require_relative '../models/swiss_locations'
MgeoIndex = Picky::Index.new :memory_geo do
  source          { SwissLocations.all('data/ch.csv', col_sep: ",") }
  category        :location
  ranged_category :north1, 0.008, precision: 3, from: :north
  ranged_category :east1,  0.008, precision: 3, from: :east
end