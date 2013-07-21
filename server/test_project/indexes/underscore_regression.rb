Picky::Index.new :underscore_regression do
  key_format :to_i
  source   { SwissLocations.all('data/ch.csv', col_sep: ",") }
  category :some_place, :from => :location
end