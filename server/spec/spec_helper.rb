if ENV['COV']
  require 'simplecov'
  SimpleCov.adapters.define 'picky' do
    add_filter '/spec/'
    add_group  'Libraries', 'lib'
  end
  SimpleCov.start 'picky'
end
# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['PICKY_ENV'] = 'test'
require File.expand_path '../../lib/picky', __FILE__
require 'spec'

# Set some spec preconditions.
#
Object.send :remove_const, :PICKY_ROOT
PICKY_ROOT = 'spec/test_directory'
puts "Redefined PICKY_ROOT to '#{PICKY_ROOT}' for the tests."

PickyLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

def performance_of
  if block_given?
    GC.disable
    result = Benchmark.realtime &Proc.new
    GC.enable
    result
  else
    raise "#performance_of needs a block"
  end
end