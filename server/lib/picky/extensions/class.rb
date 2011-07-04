# The original Class class.
#
class Class # :nodoc:all

  def instance_delegate *methods
    methods.each do |method|
      module_eval("def self.#{method}(*args, &block)\nself.instance.__send__(#{method.inspect}, *args, &block)\nend\n", "(__DELEGATION__)", 1)
    end
  end

end