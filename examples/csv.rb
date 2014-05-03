# Copy this into a Ruby file "csvsearch.rb", then:
#   ruby csvsearch.rb

require 'picky'
require 'csv'
require 'ostruct'
require 'fileutils'

# Prepare CSV data.
#
options = {
  headers: true,
  header_converters: ->(header) { header.to_sym }
}
csv = CSV.open('./people.csv', options)
         .to_a
         .map { |row| OpenStruct.new row.to_hash }

# Define an index.
#
data = Picky::Index.new :people do
  source { csv }
  category :age
  category :name
end

# The index is saved into './index'.
#
data.index

# Create a search interface object.
#
people = Picky::Search.new data

# Do a search and remember the results.
#
results = people.search 'age:36'

# Show the results.
#
p results.ids # => ["2"]