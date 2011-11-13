require File.expand_path '../app', __FILE__

# Load all indexes.
#
Picky::Indexes.reload

# Use Harakiri middleware to kill unicorn child after X requests.
#
# See http://vimeo.com/12614970 for more info.
#
# Picky::Rack::Harakiri.after = 1000
# use Picky::Rack::Harakiri

run BookSearch.new