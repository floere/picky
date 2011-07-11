module Backend

  class Files < Base

    def initialize bundle
      super bundle

      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @inverted      = File::JSON.new    bundle.index_path(:inverted)
      @weights       = File::JSON.new    bundle.index_path(:weights)
      @similarity    = File::Marshal.new bundle.index_path(:similarity)
      @configuration = File::JSON.new    bundle.index_path(:configuration)
    end

    def to_s
      "#{self.class}(#{[@inverted, @weights, @similarity, @configuration].join(', ')})"
    end

  end

end