require File.expand_path('../integration', __FILE__)

t = Time.now

map = Rust::HashMap.new
p map.set('hello', 12345)
p map.get('hello')
p map.get('hell')

p Time.now - t