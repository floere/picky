# Extensions for the Hash.
#
class Hash
  
  # Dumps binary self to the path given.
  #
  def dump_to path
    File.open(path, 'w:binary') { |out_file| Marshal.dump self, out_file }
  end
  
end