# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['PICKY_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + '/../lib/picky')
require 'spec'

# Set some spec preconditions.
#
Object.send :remove_const, :PICKY_ROOT
PICKY_ROOT = 'some/search/root'
puts "Redefined PICKY_ROOT to '#{PICKY_ROOT}' for the tests."

PickyLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."