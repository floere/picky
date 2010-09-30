begin
  require 'bundler'
rescue LoadError => e
  require 'rubygems'
  require 'bundler'
end
Bundler.setup SEARCH_ENVIRONMENT
Bundler.require