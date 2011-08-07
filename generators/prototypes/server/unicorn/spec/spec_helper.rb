ENV['PICKY_ENV'] = 'test'

require 'picky'

SearchLog = Picky::Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

Picky::Loader.load_application