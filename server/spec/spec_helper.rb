# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['PICKY_ENV'] = 'test'
require File.expand_path '../../lib/picky', __FILE__
require 'spec'

# Set some spec preconditions.
#
Object.send :remove_const, :PICKY_ROOT
PICKY_ROOT = 'some/search/root'
puts "Redefined PICKY_ROOT to '#{PICKY_ROOT}' for the tests."

PickyLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

def performance_of &block
  GC.disable
  result = Benchmark.realtime &block
  GC.enable
  result
end