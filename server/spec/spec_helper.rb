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

# Set some spec preconditions.
#
Picky.root = 'spec/test_directory'
# puts "Redefined Picky.root to '#{Picky.root}' for the tests."

Picky.logger = Picky::Loggers::Silent.new STDOUT
# puts "Using Picky::Loggers::Silent.new(STDOUT) as test logger."

class Object
  def exclaim(*)
    # The sound of silence.
  end
end

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