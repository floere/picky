module Picky

  class Bundle

    # Removes the given id from the indexes.
    #
    def remove id
      # Is it anywhere?
      #
      str_or_syms = @realtime[id]

      return if str_or_syms.blank?

      str_or_syms.each do |str_or_sym|
        ids = @inverted[str_or_sym]
        ids.delete id

        if ids.empty?
          @inverted.delete str_or_sym
          @weights.delete  str_or_sym

          # Since no element uses this sym anymore, we can delete the similarity for it.
          # TODO Not really. Since multiple syms can point to the same encoded.
          #
          @similarity.delete self.similarity_strategy.encoded(str_or_sym)
        else
          @weights[str_or_sym] = self.weights_strategy.weight_for ids.size
        end
      end

      @realtime.delete id
    end

    # Returns a reference to the array where the id has been added.
    #
    def add id, str_or_sym, where = :unshift
      str_or_syms = @realtime[id] ||= []

      # Inverted.
      #
      ids = if str_or_syms.include? str_or_sym
        ids = @inverted[str_or_sym]
        ids.delete id
        ids.send where, id
      else
        # Update the realtime index.
        #
        str_or_syms << str_or_sym

        # TODO Introduce a new method?
        #
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
        similars = @similarity[encoded] ||= []

        # Not completely correct, as others will also be affected, but meh.
        #
        similars.delete str_or_sym if similars.include? str_or_sym
        similars.send where, str_or_sym
      end
    end

    # Partializes the text and then adds each.
    #
    def add_partialized id, text, where = :unshift
      self.partial_strategy.each_partial text do |partial_text|
        add id, partial_text, where
      end
    end

    # Builds the realtime mapping.
    #
    # Note: Experimental feature.
    #
    # TODO Subset of #add. Rewrite.
    #
    def build_realtime
      clear_realtime
      @inverted.each_pair do |str_or_sym, ids|
        ids.each do |id|
          str_or_syms = @realtime[id] ||= []
          @realtime[id] << str_or_sym unless str_or_syms.include? str_or_sym
        end
      end
    end

  end

end
