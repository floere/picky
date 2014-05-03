# Copy this into a Ruby file "dump_load_search.rb", then:
#   ruby dump_load_search.rb

require 'fileutils'
require 'picky'

# Make Picky be quiet.
#
Picky.logger = Picky::Loggers::Silent.new

# Create an index.
# Note that :id is implied - every input
# object must supply an :id!
#
index = Picky::Index.new :people do
  category :age
  category :name
end

# Define a data input class. Any object that responds to
# :id, :age, :name can be added to the index.
#
Person = Struct.new :id, :age, :name

# Add some data objects to the index.
# IDs can be any unique string or integer.
#
index.add Person.new(1, 34, 'Florian is the author of picky')
index.add Person.new(2, 77, 'Floris is related to Florian')

# Create a search interface object to search the index.
#
people = Picky::Search.new index

# The index data is saved into './index' when you
# run index.dump().
# But you still find results.
#
index.dump
p people.search('flori').ids # => [2, 1]

# Clearing the index will empty it in memory.
#
index.clear
p people.search('flori').ids # => []

# Loading the index will fill the index again.
#
index.load
p people.search('flori').ids # => [2, 1]