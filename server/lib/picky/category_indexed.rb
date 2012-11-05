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
    # TODO Make range query code faster.
    #
    def weight token
      bundle = bundle_for token
      if range = token.range
        # The math is not perfectly correct, but you
        # get my idea. Also, we could return early.
        #
        range.inject(0) { |sum, text| sum + (bundle.weight(text) || 0) }
      else
        bundle.weight token.text
      end
    end

    # Gets the ids for this token's text.
    #
    # TODO Make range query code faster.
    #
    def ids token
      bundle = bundle_for token
      if range = token.range
        range.inject([]) { |result, text| result + bundle.ids(text) }.flatten
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