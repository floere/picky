# Extensions for the Hash.
#
class Hash
  
  # Dumps jsonized self to the path given. Minus extension.
  #
  def dump_to_json path
    File.open("#{path}.json", 'w') do |out_file|
      Yajl::Encoder.encode self, out_file
    end
  end
  
  # Dumps binary self to the path given. Minus extension.
  #
  def dump_to_marshalled path
    File.open("#{path}.dump", 'w:binary') do |out_file|
      Marshal.dump self, out_file
    end
  end
  
  # Use yajl's encoding.
  #
  def to_json options = {}
    Yajl::Encoder.encode self, options
  end
  
end