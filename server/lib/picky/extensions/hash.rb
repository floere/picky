# Extensions for the Hash.
#
class Hash # :nodoc:all

  # Dumps jsonized self to the path given. Minus extension.
  #
  def dump_json path
    File.open(path, 'w') do |out_file|
      Yajl::Encoder.encode self, out_file
    end
  end

  # Dumps binary self to the path given. Minus extension.
  #
  # TODO Rename dump_marshal.
  #
  def dump_marshalled path
    File.open(path, 'w:binary') do |out_file|
      Marshal.dump self, out_file
    end
  end

  # Use yajl's encoding.
  #
  def to_json options = {}
    Yajl::Encoder.encode self, options
  end

end