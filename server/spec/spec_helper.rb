if ENV['COV']
  require 'simplecov'
  SimpleCov.adapters.define 'picky' do
    add_filter '/spec/'
    add_group  'Libraries', 'lib'
  end
  SimpleCov.start 'picky'
end

ENV['PICKY_ENV'] = 'test'
require_relative '../lib/picky'

# Set some spec preconditions.
#
Picky.root   = 'spec/temp'
Picky.logger = Picky::Loggers::Silent.new

begin
  # Remove this file for the default.
  #
  require_relative 'performance_ratio'
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
    raise '#performance_of needs a block'
  end
end
def gc_runs_of
  if block_given?
    code = Proc.new
    GC.start
    calls = GC.count
    code.call
    GC.count - calls
  else
    raise '#gc_runs_of needs a block'
  end
end