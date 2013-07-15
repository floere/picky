module Picky

  #
  #
  class Category

    # Loads the index from cache.
    #
    def load
      Picky.logger.load self
      clear_realtime # THINK Should we really explicitly clear the realtime? Or should it just be loaded?
      exact.load
      partial.load
    end

    # Gets the weight for this token's text.
    #
    def weight token
      bundle = bundle_for token
      if range = token.range
        # TODO We might be able to return early?
        #
        @ranger.new(*range).inject(nil) do |sum, text|
          weight = token.weight bundle
          weight && (weight + (sum || 0)) || sum
        end
      else
        token.weight bundle
      end
    end

    # Gets the ids for this token's text.
    #
    # TODO Invert again? token.ids(bundle)
    #
    def ids token
      p [:ci_ids, token]
      bundle = bundle_for token
      if range = token.range
        # Adding all to an array, then flattening
        # is faster than using ary + ary.
        #
        @ranger.new(*range).inject([]) do |result, text|
          # It is 30% faster using the empty check
          # than just << [].
          #
          ids = token.ids bundle
          ids.empty? ? result : result << ids
        end.flatten
      else
        token.ids bundle
      end
    end

    # Returns the right index bundle for this token.
    #
    def bundle_for token
      token.partial? ? partial : exact
    end

    # Returns a combination for the token,
    # or nil, if there is none.
    #
    # TODO Don't throw away the weight, instead store it in the combination?
    #
    def combination_for token
      weight(token) && Query::Combination.new(token, self)
    end

  end

end
