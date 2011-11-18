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
    def add id, str_or_sym, where = :unshift
      ary = @inverted[str_or_sym]

      str_or_syms = @realtime_mapping[id]
      str_or_syms = (@realtime_mapping[id] = []) unless str_or_syms # TODO Nicefy.

      # Inverted.
      #
      ids = if str_or_syms.include? str_or_sym
        ids = @inverted[str_or_sym]
        ids.delete id
        ids.send where, id
      else
        str_or_syms << str_or_sym
        ids = @inverted[str_or_sym] ||= []
        ids.send where, id
      end

      # Weights.
      #
      @weights[str_or_sym] = self.weights_strategy.weight_for ids.size

      # Similarity.
      #
      add_similarity str_or_sym, where

      # Return reference.
      #
      ids
    end

    # Add string/symbol to similarity index.
    #
    # TODO Probably where makes no sense here. Should have its own order.
    #
    def add_similarity str_or_sym, where = :unshift
      if encoded = self.similarity_strategy.encoded(str_or_sym)
        similarity = @similarity[encoded] ||= []
        if similarity.include? str_or_sym
          similarity.delete str_or_sym  # Not completely correct, as others will also be affected, but meh.
          similarity.send where, str_or_sym #
        else
          similarity.send where, str_or_sym
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