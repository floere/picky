# Set constants.
#

# Use rack's environment for the search engine.
#
ENV['SEARCH_ENV'] ||= ENV['RACK_ENV']

SEARCH_ENVIRONMENT = ENV['SEARCH_ENV'] || 'development' unless defined? SEARCH_ENVIRONMENT
SEARCH_ROOT        = Dir.pwd unless defined? SEARCH_ROOT