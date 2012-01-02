require File.expand_path '../app', __FILE__

# Load all indexes.
#
Picky::Indexes.load

run ExternalDataSearch.new