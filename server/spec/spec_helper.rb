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

begin
  require File.expand_path '../performance_ratio', __FILE__
rescue LoadError => e
  # Default is for slower computers and
  # collaborators who don't need to check
  # performance so much.
  #
  module Picky; PerformanceRatio = 0.5 end
end
def performance_of
  if block_given?
    code = Proc.new
    GC.disable
    t0 = Time.now
    code.call
    t1 = Time.now
    GC.enable
    (t1 - t0) * Picky::PerformanceRatio
  else
    raise "#performance_of needs a block"
  end
end