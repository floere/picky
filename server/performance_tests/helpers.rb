class Object; def timed_exclaim(_); end end

def performance_of
  raise '#performance_of needs a block' unless block_given?

  code = Proc.new
  GC.disable
  t0 = Time.now
  code.call
  t1 = Time.now
  GC.enable
  (t1 - t0)
end

def compare_strings
  s1 = []
  ObjectSpace.each_object(String) do |s|
    s1 << s
  end

  yield

  s2 = []
  ObjectSpace.each_object(String) do |s|
    s2 << s
  end

  p s2 - s1
end

def ram(file_name)
  # Demeter is rotating in her grave :D
  #
  `ps u`.split("\n").select { |line| line.include? file_name }.first.split(/\s+/)[5].to_i
end

def string_count
  i = 0
  GC.start
  ObjectSpace.each_object(String) do |_s|
    # puts s
    i += 1
  end
  i
end

def runs
  GC::Profiler.result.match(/\d+/)[0].to_i
end

class Array
  def sum
    inject(0) { |result, value| result + value }
  end
end
