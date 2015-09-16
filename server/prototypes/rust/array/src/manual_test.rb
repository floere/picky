require File.expand_path('../integration', __FILE__)

def mem
  GC.start
  puts `ps aux | grep #{Process.pid}`.split("\n").find { |s| s.match(/manual_test/) }
end

t = Time.now

ary = ('a'..'z').to_a

puts `ps aux | head -1`

mem

ary = Rust::Array.new
100_000.times do |i|
  ary.append(i)
end

mem

ruby_ary = Array.new
100_000.times do |i|
  ruby_ary << i
end

mem

p [ary.first, ary.last]
p [ruby_ary.first, ruby_ary.last]

p Time.now - t