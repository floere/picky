module Backend

  class Files < Base

    def initialize bundle_name, category
      super bundle_name, category

      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @inverted      = File::JSON.new    category.index_path(bundle_name, :inverted)
      @weights       = File::JSON.new    category.index_path(bundle_name, :weights)
      @similarity    = File::Marshal.new category.index_path(bundle_name, :similarity)
      @configuration = File::JSON.new    category.index_path(bundle_name, :configuration)
    end

    def to_s
      "#{self.class}(#{[@prepared, @inverted, @weights, @similarity, @configuration].join(', ')})"
    end

  end

end