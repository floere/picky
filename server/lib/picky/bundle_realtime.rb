module Picky

  class Bundle

    # Removes the given id from the indexes.
    #
    def remove id
      # Is it anywhere?
      #
      syms = @realtime_mapping[id]
      return unless syms

      syms.each do |sym|
        ids = @inverted[sym]
        ids.delete id

        encoded = self.similarity_strategy.encoded sym

        if ids.empty?
          @inverted.delete   sym
          @weights.delete    sym
          # Since no element uses this sym anymore, we can delete the similarity for it.
          # TODO Not really. Since multiple syms can point to the same encoded.
          @similarity.delete encoded
        else
          @weights[sym] = self.weights_strategy.weight_for ids.size
        end
      end

      @realtime_mapping.delete id
    end

    # Returns a reference to the array where the id has been added.
    #
    # TODO Rename sym.
    #
    def add id, sym, where = :unshift
      ary = @inverted[sym]

      syms = @realtime_mapping[id]
      syms = (@realtime_mapping[id] = []) unless syms # TODO Nicefy.

      # Inverted.
      #
      ids = if syms.include? sym
        ids = @inverted[sym]
        ids.delete  id
        ids.send where, id
      else
        syms << sym
        ids = @inverted[sym] ||= []
        ids.send where, id
      end

      # Weights.
      #
      @weights[sym] = self.weights_strategy.weight_for ids.size

      # Similarity.
      #
      if encoded = self.similarity_strategy.encoded(sym)
        similarity = @similarity[encoded] ||= []
        if similarity.include? sym
          similarity.delete sym  # Not completely correct, as others will also be affected, but meh.
          similarity.send where, sym #
        else
          similarity.send where, sym
        end
      end
    end

    # Partializes the text and then adds each.
    #
    def add_partialized id, text, where = :unshift
      self.partial_strategy.each_partial text do |partial_text|
        add id, partial_text, where
      end
    end

    # Clears the realtime mapping.
    #
    def clear_realtime_mapping
      @realtime_mapping.clear
    end

  end

end