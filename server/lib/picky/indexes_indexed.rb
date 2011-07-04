# Registers the indexes held at runtime, for queries.
#
class Indexes
  
  instance_delegate :load_from_cache,
                    :reload
  
  each_delegate :load_from_cache,
                :to => :indexes
  
  # Reloads all indexes, one after another,
  # in the order they were added.
  #
  alias reload load_from_cache

  # Load each index, and analyze it.
  #
  # Returns a hash with the findings.
  #
  def analyze
    result = {}
    indexes.each do |index|
      index.analyze result
    end
    result
  end

end