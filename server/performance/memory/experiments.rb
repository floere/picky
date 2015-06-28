require 'memory_profiler'

require_relative "../../lib/picky"

GC.start

index = Picky::Index.new(:index) do
  # optimize :no_dump
  static
  symbol_keys true
  
  category :name
end

klass = Class.new do
  
  attr_reader :id
  attr_reader :name
  
  def initialize(id, name)
    @id = id
    @name = name
  end
  
end

thing1 = klass.new(1, "My name")
thing2 = klass.new(2, "By name")
thing3 = klass.new(3, "Ty name")
thing4 = klass.new(4, "Jy name")

result = MemoryProfiler.report do
  index.add thing1
  index.add thing2
  index.add thing3
  index.add thing4
  
  GC.start
end

result.pretty_print

puts ['total_retained', result.total_retained]
puts ['total_rtnd_mem', result.total_retained_memsize]
puts ['symbol count', Symbol.all_symbols.count]

p index[:name].exact.inverted
p index[:name].exact.weights
p index[:name].exact.similarity
p index[:name].exact.realtime

p index[:name].partial.inverted

# How many unique arrays are there?

inverted = index[:name].partial.inverted
p [:size, inverted.values.size]
p [:uniq,  inverted.values.uniq.size]

require 'objspace'

h = {}
(1..10000).each do |i|
  h[i] = i
end
p ObjectSpace.memsize_of(h)

# Array resizing - can Ruby optimise this?
a = []
old_memsize = 0
(1..1000).each do |i|
  memsize = ObjectSpace.memsize_of(a)
  puts "#{a.size}: #{memsize}" unless old_memsize == memsize
  old_memsize = memsize
  a << i
end

# Array repointing.
GC.start
h = {
  a: [1,2,3,4],
  b: [1,2,3,4]
}
p ObjectSpace.memsize_of_all(Array)
h[:b] = h[:a]
GC.start
p ObjectSpace.memsize_of_all(Array)

# ---

# require 'memory_profiler'
#
# GC.start
#
# MemoryProfiler.report do
#   h1 = { "key": "value" }
#   h2 = { "key": "value" }
#
#   key = "key"
#   h3 = {}
#   h3[key] = "value"
#   key = nil
#
#   GC.start
# end.pretty_print