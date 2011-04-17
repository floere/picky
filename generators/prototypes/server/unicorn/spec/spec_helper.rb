ENV['PICKY_ENV'] = 'test'

require 'picky'

SearchLog = Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

Loader.load_application