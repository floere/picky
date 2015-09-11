require File.expand_path('../ext/integration/integration', __FILE__)

rary1 = Rust::Array.new
# rary2 = Rust::Array.new

# p rary1
# p rary2

p rary1 << 7
p rary1 << 8
p rary1 << 9
# rary1 << 10
# rary1 << 11

p rary1.first

# rary1.print
# rary2.print
# 
# puts 'Yeah!'