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
        # The math is not perfectly correct, but you
        # get my idea. Also, we could return early.
        #
        # TODO Possible to speed up more?
        #
        ranger = @ranger.new *range

        ranger.inject(nil) do |sum, text|
          weight = bundle.weight(text)
          weight && (weight + (sum || 0)) || sum
        end
      else
        bundle.weight token.text
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
        ranger = @ranger.new *range

        ranger.inject([]) do |result, text|
          # It is 30% faster using the empty check
          # than just << [].
          #
          ids = bundle.ids text
          ids.empty? ? result : result << ids
        end.flatten
      else
        bundle.ids token.text
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
