puts 'Run `ulimit -n 3000` if specs fail.'
system 'rm -r spec/temp/*'

# Start Redis if not yet running.
#
fork do
  print "Starting redis-server... "
  `redis-server` # Gets stuck or fails, continuing.
  puts "(already running, redis-server returned #{$?.exitstatus})." unless $?.success?
end

# Coverage report.
#
if ENV['COV']
  require 'simplecov'
  SimpleCov.adapters.define 'picky' do
    add_filter '/spec/'
    add_group  'Libraries', 'lib'
  end
  SimpleCov.start 'picky'
end

# Pippi.
#
if ENV['PIPPI']
  require 'pippi'
  Pippi::AutoRunner.new(:checkset => ENV['PIPPI_CHECKSET'] || 'basic')
end

# Make RSpec shut up about deprecations.
#
RSpec.configure { |rspec| rspec.deprecation_stream = StringIO.new }

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

def mark klass = String
  GC.start
  $marked = ObjectSpace.each_object(klass).to_a
  if block_given?
    yield
    diff klass 
  end
end
def diff klass = String
  return unless $marked
  now_hash = Hash.new 0
  now = ObjectSpace.each_object(klass).to_a
  now.each { |thing| now_hash[thing] += 1 }
  
  $marked.each do |thing|
    now_hash[thing] -= 1
  end
  
  now_hash.select { |_, v| v > 0 }
end