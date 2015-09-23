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

KEYS = ['abc', 'def', 'ghi', 'jkl', 'mno']
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
ary1 << 1
ary1 << 2
ary1 << 3
ary1 << 4
ary1 << 5
ary1.length
ary1.size
ary1.slice!(3,1)
# ary1.slice!(2,1)

# ary2 = Rust::Array.new
# ary2 << 2
# ary2 << 3
# ary2 << 4

# ary1.intersect(ary2)

