require File.expand_path '../app', __FILE__

# Use Harakiri middleware to kill unicorn child after X requests.
#
# See http://vimeo.com/12614970 for more info.
#
# Rack::Harakiri.after = 1000
# use Rack::Harakiri

run UnicornApp.new