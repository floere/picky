# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['SEARCH_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + '/../lib/picky')
require 'spec'

# Set some spec preconditions.
#
Object.send :remove_const, :SEARCH_ROOT
SEARCH_ROOT = 'some/search/root'
puts "Redefined SEARCH_ROOT to '#{SEARCH_ROOT}' for the tests."

SearchLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."