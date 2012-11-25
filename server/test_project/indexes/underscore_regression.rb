Picky::Index.new :underscore_regression do
  source   { SwissLocations.all('data/ch.csv', col_sep: ",") }
  category :some_place, :from => :location
end