module Picky

  #
  #
  class Category

    # Loads the index from cache.
    #
    def load
      Picky.logger.load self
      clear_realtime # THINK Should we really explicitly clear the realtime? Or should it just be loaded?
      exact.load @symbol_keys
      partial.load @symbol_keys
    end

    # Gets the weight for this token's text.
    #
    def weight token
      bundle = bundle_for token
      if range = token.range
        # TODO We might be able to return early?
        #
        @ranger.new(*range).inject(nil) do |sum, text|
          weight = bundle.weight str_or_sym(text)
          weight && (weight + (sum || 0)) || sum
        end
      else
        if tokenizer && tokenizer.stemmer?
          bundle.weight str_or_sym(token.stem(tokenizer))
        else
          bundle.weight str_or_sym(token.text)
        end
      end
    end

    # Gets the ids for this token's text.
    #
    def ids token
      bundle = bundle_for token
      if range = token.range
        # Adding all to an array, then flattening
        # is faster than using ary + ary.
        #
        @ranger.new(*range).inject([]) do |result, text|
          # It is 30% faster using the empty check
          # than just << [].
          #
          ids = bundle.ids str_or_sym(text)
          ids.empty? ? result : result << ids
        end.flatten
      else
        # Optimization
        if tokenizer && tokenizer.stemmer?
          bundle.ids str_or_sym(token.stem(tokenizer))
        else
          bundle.ids str_or_sym(token.text)
        end
      end
    end
    
    # Gets the similars for this token's text.
    #
    def similar token
      bundle = bundle_for token
      bundle.similar str_or_sym(token.text)
    end
    
    def str_or_sym text
      if @symbol_keys
        text.to_sym
      else
        text
      end
    end

    # Returns the right index bundle for this token.
    #
    def bundle_for token
      token.select_bundle exact, partial
    end

  end

end
