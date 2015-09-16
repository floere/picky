require File.expand_path('../integration', __FILE__)

def mem
  GC.start
  puts `ps aux | grep #{Process.pid}`.split("\n").find { |s| s.match(/manual_test/) }
end

t = Time.now

ary = ('a'..'z').to_a

mem

map = Rust::HashMap.new
100_000.times do |i|
  map.set(ary.shuffle[0..9].join, i)
end

mem

hash = Hash.new
100_000.times do |i|
  hash[ary.shuffle[0..9].join] = i
end

mem

p Time.now - t