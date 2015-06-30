module Picky

  class Bundle
    
    # TODO Push methods back into the backend, so that we
    #      can apply more efficient methods tailored for
    #      each specific backends.
    #
    
    # Removes the given id from the indexes.
    #
    # TODO Simplify (and slow) this again – remove the realtime index.
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
          #
          # TODO Not really. Since multiple syms can point to the same encoded.
          # In essence, we don't know if and when we can remove it.
          # (One idea is to add an array of ids and remove from that)
          #
          @similarity.delete self.similarity_strategy.encode(str_or_sym)
        else
          @weights[str_or_sym] = self.weight_strategy.weight_for ids.size
          # @weights[str_or_sym] = self.weight_strategy.respond_to?(:[]) &&
          #                        self.weight_strategy[str_or_sym] ||
          #                        self.weight_strategy.weight_for(ids.size)
        end
      end

      @realtime.delete id
    end

    # Returns a reference to the array where the id has been added.
    #
    # Does not add to realtime if static.
    #
    # TODO What does static do again?
    # TODO Why the realtime index? Is it really necessary?
    #      Not absolutely. It was for efficient deletion/replacement.
    #
    def add id, str_or_sym, method: :unshift, static: false, force_update: false
      # If static, indexing will be slower, but will use less
      # space in the end.
      #
      if static
        ids = @inverted[str_or_sym] ||= []
        if force_update
          ids.delete id
          ids.send method, id
        else
          # TODO Adding should not change the array if it's already in.
          #
          if ids.include?(id)
            # Do nothing. Not forced, and already in.
          else
            ids.send method, id
          end
        end
      else
        # Use a generalized strategy.
        #
        str_or_syms = (@realtime[id] ||= []) # (static ? nil : []))

        # Inverted.
        #
        ids = if str_or_syms.include?(str_or_sym)
          ids = @inverted[str_or_sym] ||= []
          # If updates are forced or if it isn't in there already
          # then remove and add to the index.
          if force_update || !ids.include?(id)
            ids.delete id
            ids.send method, id
          end
          ids
        else
          # Update the realtime index.
          #
          str_or_syms << str_or_sym
          # TODO Add has_key? to index backends.
          # ids = if @inverted.has_key?(str_or_sym)
          #   @inverted[str_or_sym]
          # else
          #   @inverted[str_or_sym] = []
          # end
          ids = (@inverted[str_or_sym] ||= [])
          ids.send method, id
        end
      end
        
      # Weights.
      #
      @weights[str_or_sym] = self.weight_strategy.weight_for ids.size

      # Similarity.
      #
      add_similarity str_or_sym, method: method

      # Return reference.
      #
      ids
    end

    # Add string/symbol to similarity index.
    #
    def add_similarity str_or_sym, method: :unshift
      if encoded = self.similarity_strategy.encode(str_or_sym)
        similars = @similarity[encoded] ||= []

        # Not completely correct, as others will also be affected, but meh.
        #
        similars.delete str_or_sym if similars.include? str_or_sym
        similars << str_or_sym

        self.similarity_strategy.prioritize similars, str_or_sym
      end
    end

    # Partializes the text and then adds each.
    #
    def add_partialized id, text, method: :unshift, static: false, force_update: false
      partialized text do |partial_text|
        add id, partial_text, method: method, static: static, force_update: force_update
      end
    end
    def partialized text, &block
      self.partial_strategy.each_partial text, &block
    end

    # Builds the realtime mapping.
    #
    # Note: Experimental feature. Might be removed in 5.0.
    #
    # THINK Maybe load it and just replace the arrays with the corresponding ones.
    #
    def build_realtime symbol_keys
      clear_realtime
      @inverted.each_pair do |str_or_sym, ids|
        ids.each do |id|
          str_or_syms = (@realtime[id] ||= [])
          str_or_sym = str_or_sym.to_sym if symbol_keys
          @realtime[id] << str_or_sym unless str_or_syms.include? str_or_sym
        end
      end
    end

  end

end
