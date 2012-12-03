# The original Module class.
#
class Module
  
  def forward *methods
    to = extract_to_from_options methods,
           "Forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. forward :something, :to => :an_array_reader)."
    forwarding methods do |method|
      "def #{method}(*args, &block)\n#{to}.__send__(#{method.inspect}, *args, &block)\nend\n"
    end
  end
  
  def each_forward *methods
    to = extract_to_from_options methods,
           "Multi forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. each_forward :something, :to => :an_array_reader)."
    forwarding methods do |method|
      "def #{method}(*args, &block)\n#{to}.each{ |t| t.__send__(#{method.inspect}, *args, &block) }\nend\n"
    end
  end
  
  private
  
    def extract_to_from_options args, error_string
      options = args.pop
      unless options.is_a?(Hash) && to = options[:to]
        raise ArgumentError, "Multi forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. each_forward :something, :to => :an_array_reader)."
      end
      to
    end
  
    def forwarding methods, &method_definition
      methods.each do |method|
        module_eval method_definition[method], "(__FORWARDING__)", 1
      end
    end

end