require File.expand_path '../app', __FILE__

# Load all indexes.
#
Picky::Indexes.reload

run BookSearch.new