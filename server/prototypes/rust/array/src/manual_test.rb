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

ary = ('a'..'z').to_a

puts `ps aux | head -1`

mem

timed do
  ary = Rust::Array.new
  100_000.times do |i|
    ary.append(i)
  end
end

mem

timed do
  ruby_ary = Array.new
  100_000.times do |i|
    ruby_ary << i
  end
end

mem

p [ary.first, ary.last]
p [ruby_ary.first, ruby_ary.last]

p Time.now - t