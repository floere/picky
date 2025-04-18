require File.expand_path('integration', __dir__)

def mem
  GC.start
  puts `ps aux | grep #{Process.pid}`.split("\n").find { |s| s.match(/manual_test/) }
end

def timed
  t = Time.now
  yield
  p Time.now - t
end

TIMES = 65_000

def rust_ary
  ary = Rust::Array.new
  timed do
    TIMES.times do |i|
      ary << i
    end
  end
  ary.length
  p ary.size
  p [ary.first, ary.last]
end

def ruby_ary
  ary = Array.new
  timed do
    TIMES.times do |i|
      ary << i
    end
  end
  ary.length
  p ary.size
  p [ary.first, ary.last]
end

KEYS = %w[abc def ghi jkl mno]
def rust_hash
  hash = Rust::Hash.new
  keys_size = KEYS.size
  timed do
    TIMES.times do |i|
      key = KEYS[i % keys_size]
      hash[key] ||= Rust::Array.new
      hash[key] << i
    end
  end
end

# def rust_hash_fast_append
#   hash = Rust::Hash.new
#   keys_size = KEYS.size
#   timed do
#     TIMES.times do |i|
#       key = KEYS[i % keys_size]
#       # hash[key] ||= Rust::Array.new
#       hash.append_to(key, i)
#     end
#   end
# end
def ruby_hash
  hash = Hash.new
  keys_size = KEYS.size
  timed do
    TIMES.times do |i|
      key = KEYS[i % keys_size]
      hash[key] ||= Array.new
      hash[key] << i
    end
  end
end

# # Array
#
# puts `ps aux | head -1`
# mem
# rust_ary
# mem
# ruby_ary
# mem

# # Hash
#
# puts `ps aux | head -1`
# mem
# # rust_hash_fast_append
# # mem
# rust_hash
# mem
# ruby_hash
# mem

# Other

ary1 = Rust::Array.new
p ary1 << 1
p ary1 << 2
p ary1 << 3
p ary1 << 4
p ary1 << 5
p ary1 << 6
p [:shift, ary1.shift]
puts ary1.inspect

p [:first, ary1.first]
p [:last, ary1.last]
p [:length, ary1.length]
p [:size, ary1.size]

ary2 = Rust::Array.new
ary2 << 5
ary2 << 6
ary2 << 7
p ary2
p [:size, ary2.size]
p ary2

p [:intersect, ary1.intersect(ary2.to_ptr)]

p [:slice!, ary1.slice!(2,2)]

p ary1
