if version = ENV['PICKY_VERSION']
  Bundler.require
  require_relative 'definition'
  puts version
else
  require 'yajl'
  require_relative '../server/lib/picky'
  require_relative 'definition'
end

Picky::Indexes.index