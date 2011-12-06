module Picky

  #
  #
  class Category

    # Loads the index from cache.
    #
    def load
      timed_exclaim %Q{  "#{identifier}": Loading index from cache.}
      clear_realtime # THINK Should we really explicitly clear the realtime? Or should it just be loaded?
      exact.load
      partial.load
    end

    # Gets the weight for this token's text.
    #
    def weight token
      bundle_for(token).weight token.text
    end

    # Gets the ids for this token's text.
    #
    def ids token
      bundle_for(token).ids token.text
    end

    # Returns the right index bundle for this token.
    #
    def bundle_for token
      token.partial? ? partial : exact
    end

    # Returns a combination for the token,
    # or nil, if there is none.
    #
    def combination_for token
      weight(token) && Query::Combination.new(token, self)
    end

  end

end