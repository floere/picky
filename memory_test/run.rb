Bundler.require
require_relative 'definition'

# For Pickies that don't have that baked into.
#
MultiJson.use :yajl if defined? MultiJson

puts ENV['PICKY_VERSION'] || 'Latest version (pid, rss, command)'

Picky::Indexes.load

# p Picky::Search.new(Picky::Indexes[:memory]).search 'rfrdpmahxrruqzqrhszipsfltrspyq'

puts `ps -e -www -o pid,rss,command | grep 'ruby \\brun.rb'`
puts