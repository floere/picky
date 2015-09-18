require File.expand_path('../integration', __FILE__)

def mem
  GC.start
  puts `ps aux | grep #{Process.pid}`.split("\n").find { |s| s.match(/manual_test/) }
end

def timed
  t = Time.now
  yield
  p Time.now - t
end

# Array

TIMES = 65_000

ary = ('a'..'z').to_a

puts `ps aux | head -1`

mem

ary = Rust::Array.new
timed do
  TIMES.times do |i|
    ary.append(i)
  end
end

mem

ruby_ary = Array.new
timed do
  TIMES.times do |i|
    ruby_ary << i
  end
end

mem

p [ary.first, ary.last]
p [ruby_ary.first, ruby_ary.last]

# Hash

ary = ('a'..'z').to_a

puts `ps aux | head -1`

mem

hash = Rust::Hash.new

timed do
  100_000.times do |i|
    hash[ary.shuffle[0..9].join] = i
  end
end

mem

ruby_hash = Hash.new

timed do
  100_000.times do |i|
    ruby_hash[ary.shuffle[0..9].join] = i
  end
end

mem