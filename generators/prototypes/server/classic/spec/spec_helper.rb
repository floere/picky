ENV['PICKY_ENV'] = 'test'

require 'picky'

Picky.logger = Logger.new STDOUT
puts "Using STDOUT as test log."

Picky::Loader.load_application