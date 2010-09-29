module Picky
  # Use this class to extend the hash the serializer returns.
  #
  module Convenience

    # Are there any allocations?
    #
    def empty?
      allocations.empty?
    end
    # Returns the topmost limit results.
    #
    def ids limit = 20
      ids = []
      allocations.each { |allocation| allocation[4].each { |id| break if ids.size > limit; ids << id } }
      ids
    end
    # Removes the ids from each allocation.
    #
    def clear_ids
      allocations.each { |allocation| allocation[4].clear }
    end

    # Caching readers.
    #
    def allocations
      @allocations || @allocations = self[:allocations]
    end
    def allocations_size
      @allocations_size || @allocations_size = allocations.size
    end
    def total
      @total || @total = self[:total]
    end

  end
end