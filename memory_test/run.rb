Bundler.require
require_relative 'definition'

Picky::Indexes.load

puts `ps -e -www -o pid,rss,command | grep 'ruby run.rb'`