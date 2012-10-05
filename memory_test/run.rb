Bundler.require
require_relative 'definition'

# For Pickies that don't have that baked into.
#
MultiJson.use :yajl if defined? MultiJson

Picky::Indexes.load

# p Picky::Search.new(Picky::Indexes[:memory]).search 'rfrdpmahxrruqzqrhszipsfltrspyq'

puts `ps -e -www -o pid,rss,command | grep 'ruby run.rb'`