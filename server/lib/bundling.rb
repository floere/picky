# TODO Remove?
#
begin
  require 'bundler'
rescue LoadError => e
  require 'rubygems'
  retry
end
Bundler.setup SEARCH_ENVIRONMENT
Bundler.require