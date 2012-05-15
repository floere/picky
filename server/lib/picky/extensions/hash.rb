# Extensions for the Hash.
#
class Hash

  # Use yajl's encoding.
  #
  def to_json options = {}
    Yajl::Encoder.encode self, options
  end

end