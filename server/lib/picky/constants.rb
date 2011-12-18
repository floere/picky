# Set constants.
#

# Use rack's environment for the search engine.
#
ENV['PICKY_ENV'] ||= ENV['RUBY_ENV'] || ENV['RACK_ENV']

PICKY_ENVIRONMENT = ENV['PICKY_ENV'] || 'development' unless defined? PICKY_ENVIRONMENT
PICKY_ROOT        = Dir.pwd unless defined? PICKY_ROOT

EMPTY_STRING = ''.freeze unless defined? EMPTY_STRING