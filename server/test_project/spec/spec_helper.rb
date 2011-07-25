ENV['PICKY_ENV'] = 'test'

require File.expand_path '../../../lib/picky', __FILE__

SearchLog = Picky::Loggers::Search.new ::Logger.new(STDOUT)
puts "Using STDOUT as test log."

Picky::Loader.load_application