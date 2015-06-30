module Picky

  # An indexed bundle is a number of memory/redis
  # indexes that compose the indexes for a single category:
  #  * core (inverted) index
  #  * weights index
  #  * similarity index
  #  * index configuration
  #
  # Indexed refers to them being indexed.
  # This class notably offers the methods:
  #  * load
  #  * clear
  #
  # To (re)load or clear the current indexes.
  #
  class Bundle

    # Get the ids for the given symbol.
    #
    # Returns a (potentially empty) array of ids.
    #
    # Note: If the backend wants to return a special
    # enumerable, the backend should do so.
    #
    def ids str_or_sym
      @inverted[str_or_sym] || []
      # THINK Place the key_format conversion here – or move into the backend?
      #
      # if @key_format
      #   class << self
      #     def ids
      #       (@inverted[sym_or_string] || []).map &@key_format
      #     end
      #   end
      # else
      #   class << self
      #     def ids
      #       @inverted[sym_or_string] || []
      #     end
      #   end
      # end
    end

    # Get a weight for the given symbol.
    #
    # Returns a number, or nil.
    #
    def weight str_or_sym
      @weights[str_or_sym]
    end

    # Get settings for this bundle.
    #
    # Returns an object.
    #
    def [] str_or_sym
      @configuration[str_or_sym]
    end

    # Loads all indexes.
    #
    # Loading loads index objects from the backend.
    # They should each respond to [] and return something appropriate.
    #
    def load symbol_keys = false
      load_inverted symbol_keys
      load_weights symbol_keys
      load_similarity symbol_keys
      load_configuration
      load_realtime
    end

    # Loads the core index.
    #
    def load_inverted symbol_keys
      self.inverted = @backend_inverted.load symbol_keys
    end
    # Loads the weights index.
    #
    def load_weights symbol_keys
      self.weights = @backend_weights.load symbol_keys unless @weight_strategy.respond_to?(:saved?) && !@weight_strategy.saved?
    end
    # Loads the similarity index.
    #
    def load_similarity symbol_keys
      self.similarity = @backend_similarity.load symbol_keys unless @similarity_strategy.respond_to?(:saved?) && !@similarity_strategy.saved?
    end
    # Loads the configuration.
    #
    def load_configuration
      self.configuration = @backend_configuration.load false
    end
    # Loads the realtime mapping.
    #
    def load_realtime
      self.realtime = @backend_realtime.load false
    end

    # Clears all indexes.
    #
    def clear
      clear_inverted
      clear_weights
      clear_similarity
      clear_configuration
      clear_realtime
    end

    # Clears the core index.
    #
    def clear_inverted
      inverted.clear
    end
    # Clears the weights index.
    #
    def clear_weights
      weights.clear
    end
    # Clears the similarity index.
    #
    def clear_similarity
      similarity.clear
    end
    # Clears the configuration.
    #
    def clear_configuration
      configuration.clear
    end
    # Clears the realtime mapping.
    #
    def clear_realtime
      realtime.clear
    end

  end

end