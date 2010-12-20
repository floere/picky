# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
require File.expand_path '../../lib/picky-statistics', __FILE__
require 'spec'

def performance_of &block
  GC.disable
  result = Benchmark.realtime &block
  GC.enable
  result
end