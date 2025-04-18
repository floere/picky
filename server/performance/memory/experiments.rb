require 'memory_profiler'

require_relative '../../lib/picky'

GC.start

index = Picky::Index.new(:index) do
  # OPTIMIZE: no_dump
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

puts ['symbol count', Symbol.all_symbols.count]

thing1 = klass.new(1, 'My name')
index.add thing1

result = MemoryProfiler.report do
  index.add thing1
end

result.pretty_print

puts ['total_retained', result.total_retained]
puts ['total_rtnd_mem', result.total_retained_memsize]
puts ['symbol count', Symbol.all_symbols.count]

# p index[:name].exact.inverted
# p index[:name].exact.weights
# p index[:name].exact.similarity
# p index[:name].exact.realtime
#
# p index[:name].partial.inverted

# # How many unique arrays are there?
#
# inverted = index[:name].partial.inverted
# p [:size, inverted.values.size]
# p [:uniq,  inverted.values.uniq.size]
#
# require 'objspace'
#
# h = {}
# (1..10000).each do |i|
#   h[i] = i
# end
# p ObjectSpace.memsize_of(h)
#
# # Array resizing - can Ruby optimise this?
# a = []
# old_memsize = 0
# (1..1000).each do |i|
#   memsize = ObjectSpace.memsize_of(a)
#   puts "#{a.size}: #{memsize}" unless old_memsize == memsize
#   old_memsize = memsize
#   a << i
# end
#
# # Array repointing.
# GC.start
# h = {
#   a: [1,2,3,4],
#   b: [1,2,3,4]
# }
# p ObjectSpace.memsize_of_all(Array)
# h[:b] = h[:a]
# GC.start
# p ObjectSpace.memsize_of_all(Array)

# ---

# def arrays
#   arys = []
#   ObjectSpace.each_object(Array) do |ary|
#     arys << ary
#   end
#   arys
# end
#
# # Remove all indexes.
# Picky::Indexes.clear_indexes
#
# index = Picky::Index.new :memory_leak do
#   symbol_keys true
#
#   category :text1
#   category :text2
#   category :text3
#   category :text4
# end
# try = Picky::Search.new index
#
# thing = Struct.new(:id, :text1, :text2, :text3, :text4)
#
# GC.start
# index.add thing.new(1, 'one', 'two', 'three', 'four')
# GC.start
#
# require 'memory_profiler'
#
# old_arys = Set.new(arrays)
#
# result = MemoryProfiler.report do
#   GC.start
#   index.add thing.new(1, 'one', 'two', 'three', 'seven')
#   GC.start
# end
#
# new_arys = Set.new(arrays)
#
# GC.start
#
# puts "old: #{old_arys.size}"
# puts "new: #{new_arys.size}"
#
# GC.start
#
# diff = new_arys - old_arys
# # p diff.size
# diff.each do |thing|
#   if thing.size < 10
#     # p thing
#   end
# end

# result = MemoryProfiler.report do
#   GC.start
#   index.add thing.new(1, 'one', 'two', 'three', 'seven')
#   GC.start
# end

# result.pretty_print

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
