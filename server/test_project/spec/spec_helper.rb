# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
#
ENV['PICKY_ENV'] = 'test'
require 'rubygems'
require File.expand_path '../../../lib/picky', __FILE__
require 'spec'

SearchLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

Loader.load_application

# TODO Not ok.
#
BookSearch.finalize