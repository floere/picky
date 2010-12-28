module Query
  # Container class for allocations.
  #
  class Allocations # :nodoc:all

    # TODO Remove size
    #
    delegate :each, :inject, :empty?, :size, :to => :@allocations
    attr_reader :total

    def initialize allocations = []
      @allocations = allocations
    end

    # Score each allocation.
    #
    def calculate_score weights
      @allocations.each do |allocation|
        allocation.calculate_score weights
      end
    end
    # Sort the allocations.
    #
    def sort
      @allocations.sort!
    end

    # Reduces the amount of allocations to x.
    #
    def reduce_to amount
      @allocations = @allocations.shift amount
    end

    # Keeps combinations.
    #
    # Only those passed in remain.
    #
    def keep identifiers = []
      @allocations.each { |allocation| allocation.keep identifiers } unless identifiers.empty?
    end
    # Removes combinations.
    #
    # Only those passed in are removed.
    #
    # TODO Rewrite
    #
    def remove identifiers = []
      @allocations.each { |allocation| allocation.remove identifiers } unless identifiers.empty?
    end

    # Returns the top amount ids.
    #
    def ids amount = 20
      @allocations.inject([]) do |total, allocation|
        total.size >= amount ? (return total.shift(amount)) : total + allocation.ids
      end
    end

    # Returns a random id from the allocations.
    #
    # Note: This is an ok algorithm for small id sets.
    #
    # But still TODO try for a faster one.
    #
    def random_ids amount = 1
      return [] if @allocations.empty?
      ids = @allocations.first.ids
      indexes = Array.new(ids.size) { |id| id }.sort_by { rand }
      indexes.first(amount).map { |id| ids[id] }
    end

    # This is the main method of this class that will replace ids and count.
    #
    # What it does is calculate the ids and counts of its allocations
    # for being used in the results. It also calculates the total
    #
    # Parameters:
    #  * amount: the amount of ids to calculate
    #  * offset: the offset from where in the result set to take the ids
    #
    # Note: With an amount of 0, an offset > 0 doesn't make much
    #       sense, as seen in the live search.
    #
    # Note: Each allocation caches its count, but not its ids (thrown away).
    #       The ids are cached in this class.
    #
    # Note: It's possible that no ids are returned by an allocation, but a count. (In case of an offset)
    #
    def process! amount, offset = 0
      @total = 0
      current_offset = 0
      @allocations.each do |allocation|
        ids = allocation.process! amount, offset
        @total = @total + allocation.count # the total mixed in
        if ids.empty?
          offset = offset - allocation.count unless offset.zero?
        else
          amount = amount - ids.size # we need less results from the following allocation
          offset = 0                 # we have already passed the offset
        end
      end
    end

    def uniq
      @allocations.uniq!
    end

    def to_a
      @allocations
    end

    # Simply inspects the internal allocations.
    #
    def to_s
      @allocations.inspect
    end

    # Allocations for results are in the form:
    # [
    #   allocation1.to_result,
    #   allocation2.to_result
    #   ...
    # ]
    #
    def to_result
      @allocations.map(&:to_result).compact
    end

  end
end