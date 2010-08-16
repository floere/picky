# Add dirname to load path. TODO Necessary?
#
$:.unshift File.dirname(__FILE__)

# Require the constants.
#
# TODO Move to app?
#
require 'constants'

# Library bundling.
#
require 'bundling'

# Loader which handles framework and app loading.
#
require 'picky/loader'

# Load the framework
#
Loader.load_framework
puts "Loaded picky with environment '#{SEARCH_ENVIRONMENT}' in #{SEARCH_ROOT} on Ruby #{RUBY_VERSION}."