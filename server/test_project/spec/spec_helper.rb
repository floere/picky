# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['SEARCH_ENV'] = 'test'
require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/picky")
require 'spec'



# Set some spec preconditions.
#
SEARCH_ROOT = File.join SEARCH_ROOT, 'test_project'
puts "Redefined SEARCH_ROOT to '#{SEARCH_ROOT}' for the tests."

SearchLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."



Loader.load_application