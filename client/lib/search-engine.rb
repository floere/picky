$KCODE = 'UTF-8' unless RUBY_VERSION > '1.8.7'

require 'rubygems'

require 'active_support'

this = File.dirname __FILE__
require File.join(this, '/search/engine')
require File.join(this, '/search/serializer')
require File.join(this, '/search/convenience')