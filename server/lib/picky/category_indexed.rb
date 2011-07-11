#
#
class Category

  attr_reader :indexed_exact,
              :indexed_partial

  # Loads the index from cache.
  #
  def load_from_cache
    timed_exclaim %Q{"#{identifier}": Loading index from cache.}
    indexed_exact.load
    indexed_partial.load
  end
  alias reload load_from_cache

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
    token.partial? ? indexed_partial : indexed_exact
  end

  # Returns a combination for the token,
  # or nil, if there is none.
  #
  def combination_for token
    weight(token) && Query::Combination.new(token, self)
  end

end