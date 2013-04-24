# The original Module class.
#
class Module
  
  def forward *methods
    forwarding methods,
      'def %{method}(*args, &block); %{to}.__send__(:%{method}, *args, &block); end',
      'Forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. forward :something, :to => :a_reader).'
  end
  
  def each_forward *methods
    forwarding methods,
      'def %{method}(*args, &block); %{to}.each{ |t| t.__send__(:%{method}, *args, &block) }; end',
      'Multi forwarding needs a target. Supply an options hash with a :to key as the last argument (e.g. each_forward :something, :to => :an_array_reader).'
  end
  
  private
  
    def forwarding methods, method_definition_template, error_message = nil
      to = extract_to_from_options methods, error_message
      methods.each do |method|
        method_definition = method_definition_template % { to: to, method: method }
        module_eval method_definition, "(__FORWARDING__)", 1
      end
    end
    
    def extract_to_from_options args, error_message
      options = args.pop
      unless options.is_a?(Hash) && to = options[:to]
        raise ArgumentError, error_message
      end
      to
    end

end