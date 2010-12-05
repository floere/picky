# The original Module class.
#
class Module # :nodoc:all

  def each_delegate *methods
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Multi delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :something, :to => :an_array_reader)."
    end
    methods.each do |method|
      module_eval("def #{method}(*args, &block)\n#{to}.each{ |t| t.__send__(#{method.inspect}, *args, &block) }\nend\n", "(__DELEGATION__)", 1)
    end
  end

end