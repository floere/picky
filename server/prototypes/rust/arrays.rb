require './target/release/arrays'

array1 = Rust::Array.new
array2 = Rust::Array.new

array1.intersect(array2)

puts 'Yeah!'