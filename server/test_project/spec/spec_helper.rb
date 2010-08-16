# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['SEARCH_ENV'] = 'test'
require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/picky")
require 'spec'

Loader.load_application