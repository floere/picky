require File.expand_path 'app', __dir__

# Load all indexes.
#
Picky::Indexes.load

run ExternalDataSearch.new