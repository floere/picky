# Extensions for the Hash.
#
class Hash
  
  # Dumps binary self to the path given.
  #
  # TODO Still used? If yes, spec!
  #
  def dump_to path
    File.open(path, 'w:binary') { |out_file| Marshal.dump self, out_file }
  end
  
  # Use yajl's encoding.
  #
  def to_json options = {}
    Yajl::Encoder.encode self, options
  end
  
end