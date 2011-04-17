ENV['PICKY_ENV'] = 'test'

# require File.expand_path '../../../lib/picky', __FILE__
require 'picky'

SearchLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

Loader.load_application