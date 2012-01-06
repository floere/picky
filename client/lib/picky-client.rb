$KCODE = 'UTF-8' if RUBY_VERSION < '1.9.0'

require 'rubygems'
require 'yajl'

dir = File.dirname __FILE__
require File.expand_path('picky-client/client', dir)
require File.expand_path('picky-client/convenience', dir)
require File.expand_path('picky-client/helper', dir)
require File.expand_path('picky-client/extensions/object', dir)

require File.expand_path('picky-client/client/active_record', dir)