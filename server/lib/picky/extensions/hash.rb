# Extensions for the Hash.
#
class Hash # :nodoc:all

  # Use yajl's encoding.
  #
  def to_json options = {}
    Yajl::Encoder.encode self, options
  end

end