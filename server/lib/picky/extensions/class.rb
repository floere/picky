# The original Class class.
#
class Class

  def instance_forward *method_names
    method_names.each do |method_name|
      module_eval(<<-FORWARDING, "(__INSTANCE_FORWARDING__)", 1)
def self.#{method_name}(*args, &block)\n  self.instance.#{method_name}(*args, &block)\nend\n
FORWARDING
    end
  end

end