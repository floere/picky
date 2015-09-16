require File.expand_path('../integration', __FILE__)

t = Time.now

rary1 = Rust::Array.new
# rary2 = Rust::Array.new

# p rary1
# p rary2

rary1 << 7
rary1 << 8
rary1 << 9
rary1 << 10
rary1 << 11

rary1.first

p Time.now - t

# rary1.print
# rary2.print
# 
# puts 'Yeah!'