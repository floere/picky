# The original Class class.
#
class Class

  def instance_delegate *method_names
    method_names.each do |method_name|
      module_eval(<<-DELEGATION, "(__DELEGATION__)", 1)
def self.#{method_name}(*args, &block)\n  self.instance.#{method_name}(*args, &block)\nend
DELEGATION
    end
  end

end