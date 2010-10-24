# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV['SEARCH_ENV'] = 'test'
require File.expand_path('../../lib/picky-client', __FILE__)
require File.expand_path('../../lib/picky-client/generator', __FILE__)
require 'spec'
require 'benchmark'

require 'yajl'

def in_the(object, &block)
  object.instance_eval &block
end