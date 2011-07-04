#
#
class Category

  # TODO Move to Index.
  #
  def generate_qualifiers_from options
    options[:qualifiers] || options[:qualifier] && [options[:qualifier]]
  end

  # Loads the index from cache.
  #
  def load_from_cache
    timed_exclaim %Q{"#{identifier}": Loading index from cache.}
    indexed_exact.load
    indexed_partial.load
  end
  alias reload load_from_cache

  # Loads, analyzes, and clears the index.
  #
  # Note: The idea is not to run this while the search engine is running.
  #
  def analyze collector
    collector[identifier] = {
      :exact   => Analyzer.new.analyze(exact),
      :partial => Analyzer.new.analyze(partial)
    }
    collector
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
    token.partial?? indexed_partial : indexed_exact
  end

  # The partial strategy defines whether to really use the partial index.
  #
  def partial
    @partial_strategy.use_exact_for_partial?? @indexed_exact : @indexed_partial
  end

  #
  #
  def combination_for token
    weight(token) && Query::Combination.new(token, self)
  end

end