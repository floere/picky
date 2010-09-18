# Require the constants.
#
# TODO Move to app?
#
require File.expand_path(File.join(File.dirname(__FILE__), 'constants'))

# Library bundling.
#
require File.expand_path(File.join(File.dirname(__FILE__), 'bundling'))

# Loader which handles framework and app loading.
#
require File.expand_path(File.join(File.dirname(__FILE__), 'picky', 'loader'))

# Load the framework
#
Loader.load_framework
puts "Loaded picky with environment '#{SEARCH_ENVIRONMENT}' in #{SEARCH_ROOT} on Ruby #{RUBY_VERSION}."