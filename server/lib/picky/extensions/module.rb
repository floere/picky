# The original Module class.
#
class Module
  
  def forward *methods
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. forward :something, :to => :an_array_reader)."
    end
    methods.each do |method|
      module_eval("def #{method}(*args, &block)\n#{to}.__send__(#{method.inspect}, *args, &block)\nend\n", "(__FORWARDING__)", 1)
    end
  end
  
  def each_forward *methods
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Multi forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. each_forward :something, :to => :an_array_reader)."
    end
    methods.each do |method|
      module_eval("def #{method}(*args, &block)\n#{to}.each{ |t| t.__send__(#{method.inspect}, *args, &block) }\nend\n", "(__MULTI_FORWARDING__)", 1)
    end
  end

end