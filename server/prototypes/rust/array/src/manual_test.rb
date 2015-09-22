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

TIMES = 10

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
  # We are getting the stored object back when get-ting.
  some_hash = Rust::Hash.new
  some_ary  = Rust::Array.new
  # some_ary << 25
  p [:hash_key_bef, some_hash['test'], some_ary]
  some_hash['test'] = some_ary
  puts
  p [:hash_key_aft, some_hash['test'], some_ary]
  p [:hash_key_aft, some_hash['test'], some_ary]
  p [:hash_key_aft, some_hash['test'].address, some_ary.address]
  p [:array_pointer_equal, some_hash['test'].address == some_ary.address]
  puts
  some_hash['test'] << 13
  some_hash['test'] << 26
  p "Stored: #{some_hash['test']}"
  
  # hash = Rust::Hash.new
  # keys_size = KEYS.size
  # timed do
  #   TIMES.times do |i|
  #     key = KEYS[0] # KEYS[i % keys_size]
  #     ary = Rust::Array.new
  #     p [:hash_key_bef, hash[key], ary]
  #     hash[key] ||= ary
  #     p [:hash_key_aft, hash[key]]
  #     p [:hash_key_app, hash[key], i]
  #     p [:appended, hash[key] << i]
  #   end
  # end
  # p [:rust_hash_length, hash.length]
  # p [:rust_hash_size, hash.size]
  # p hash['abc']
end
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
  hash.length
  p hash.size
  p hash['abc']
end

# # Array
#
# puts `ps aux | head -1`
# mem
# rust_ary
# mem
# ruby_ary
# mem

# Hash

puts `ps aux | head -1`
mem
rust_hash
mem
ruby_hash
mem

# Combined

