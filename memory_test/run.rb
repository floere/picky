if version = ENV['PICKY_VERSION']
  Bundler.require
  require_relative 'definition'
  puts version
else
  'Latest version (pid, rss, command)'
  require 'yajl'
  require_relative '../server/lib/picky'
  require_relative 'definition'
end

puts `ps -e -www -o pid,rss,command | grep 'ruby \\brun.rb'`
puts

identifier = (ENV['INDEX_NAME'] || 'memory').to_sym
index = Picky::Indexes[identifier]
t = Time.now
index.load
puts
puts "Loading time: #{Time.now - t}."

puts
puts "Inverted size: #{index[:text].exact.inverted.size}"

puts `ps -e -www -o pid,rss,command | grep 'ruby \\brun.rb'`
puts

puts "(actual) inverted size in memory: #{index[:text].exact.inverted.to_s.size}"
puts "(actual) weights size in memory: #{index[:text].exact.weights.to_s.size}"
puts "(actual) similarity size in memory: #{index[:text].exact.similarity.to_s.size}"
puts

# puts "Inverted: #{index[:text].exact.inverted}"
