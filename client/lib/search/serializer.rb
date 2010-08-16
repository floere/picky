module Search

  # This class handles serialization and deserialization.
  #
  class Serializer

    # Serialize the Results.
    #
    # Note: This code is executed on the search engine side.
    #
    def self.serialize serializable_results
      Marshal.dump serializable_results.serialize
    end

    # Create new search results from serialized ones.
    #
    # Note: This code is executed on the client side.
    #
    def self.deserialize serialized_results
      Marshal.load serialized_results
    end

  end

end