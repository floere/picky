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

ARY_TIMES = 65_000
def rust_ary
  ary = Rust::Array.new
  timed do
    ARY_TIMES.times do |i|
      ary << i
    end
  end
  p [ary.first, ary.last]
end
def ruby_ary
  ary = Array.new
  timed do
    ARY_TIMES.times do |i|
      ary << i
    end
  end
  p [ary.first, ary.last]
end

HASH_TIMES = 10 # 100_000
KEYS = ['abc', 'def', 'ghi', 'jkl', 'mno']
def rust_hash
  hash = Rust::Hash.new
  keys_size = KEYS.size
  timed do
    HASH_TIMES.times do |i|
      key = KEYS[i % keys_size]
      hash[key] ||= Rust::Array.new
      # ptr = hash[key]
      # ptr << i
      # hash[key] << i
    end
  end
  hash
end
def ruby_hash
  ruby_hash = Hash.new
  keys_size = KEYS.size
  timed do
    HASH_TIMES.times do |i|
      key = KEYS[i % keys_size]
      ruby_hash[key] ||= Array.new
      ruby_hash[key] << i
    end
  end
end

# Array

puts `ps aux | head -1`
mem
rust_ary
mem
ruby_ary
mem

# Hash

puts `ps aux | head -1`
mem
h = rust_hash
mem
ruby_hash
mem

# Combined

