# Extensions for the Hash.
#
class Hash

  # Use multi_json's encoding.
  #
  def to_json options = {}
    MultiJson.encode self, options
  end

end