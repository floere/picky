# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV['SEARCH_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + "/../lib/picky-client")
require 'spec'

def in_the(object, &block)
  object.instance_eval &block
end