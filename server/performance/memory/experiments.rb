require 'memory_profiler'

require_relative "../../lib/picky"

GC.start

index = Picky::Index.new(:index) do
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
  # index.add thing3
  # index.add thing4
  
  GC.start
end

result.pretty_print

p result.total_retained
p result.total_retained_memsize

p Symbol.all_symbols.count
