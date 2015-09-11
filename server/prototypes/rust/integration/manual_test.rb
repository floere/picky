require File.expand_path('../ext/integration/integration', __FILE__)

rary1 = Rust::Array.new
rary2 = Rust::Array.new

rary1 << 5

rary1.print
rary2.print

puts 'Yeah!'