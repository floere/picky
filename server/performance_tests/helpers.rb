class Object; def timed_exclaim(_); end end

def performance_of
  if block_given?
    code = Proc.new
    GC.disable
    t0 = Time.now
    code.call
    t1 = Time.now
    GC.enable
    (t1 - t0)
  else
    raise "#performance_of needs a block"
  end
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