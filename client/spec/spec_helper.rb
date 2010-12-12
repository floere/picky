# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
require File.expand_path('../../lib/picky-client', __FILE__)
require 'spec'
require 'benchmark'

require 'yajl'

def in_the(object, &block)
  object.instance_eval &block
end