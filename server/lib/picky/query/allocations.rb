module Picky

  module Query

    # Container class for allocations.
    #
    class Allocations # :nodoc:all

      delegate :each,
               :empty?,
               :first,
               :inject,
               :size,
               :map,
               :to => :@allocations

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
      def sort!
        @allocations.sort!
      end

      # Reduces the amount of allocations to x.
      #
      def reduce_to amount
        @allocations = @allocations.shift amount
      end

      # Removes combinations.
      #
      # Only those passed in are removed.
      #
      def remove categories = []
        @allocations.each { |allocation| allocation.remove categories } unless categories.empty?
      end

      # Returns the top amount ids.
      #
      def ids amount = 20
        @allocations.inject([]) do |total, allocation|
          total.size >= amount ? (return total.shift(amount)) : total + allocation.ids
        end
      end

      # This is the main method of this class that will replace ids and count.
      #
      # What it does is calculate the ids and counts of its allocations
      # for being used in the results. It also calculates the total
      #
      # Parameters:
      #  * amount: the amount of ids to calculate
      #  * offset: the offset from where in the result set to take the ids
      #  * terminate_early: Whether to calculate all allocations.
      #
      # Note: With an amount of 0, an offset > 0 doesn't make much
      #       sense, as seen in the live search.
      #
      # Note: Each allocation caches its count, but not its ids (thrown away).
      #       The ids are cached in this class.
      #
      # Note: It's possible that no ids are returned by an allocation, but a count. (In case of an offset)
      #
      def process! amount, offset = 0, terminate_early = nil
        each do |allocation|
          ids = allocation.process! amount, offset
          if ids.empty?
            offset = offset - allocation.count unless offset.zero?
          else
            amount = amount - ids.size # we need less results from the following allocation
            offset = 0                 # we have already passed the offset
          end
          if terminate_early && amount <= 0
            break if terminate_early <= 0
            terminate_early -= 1
          end
        end
      end

      # The total is simply the sum of the counts of all allocations.
      #
      def total
        @total ||= calculate_total
      end
      def calculate_total
        inject(0) do |total, allocation|
          total + (allocation.count or return total)
        end
      end

      def uniq
        @allocations.uniq!
      end

      def to_a
        @allocations
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

      # Simply inspects the internal allocations.
      #
      def to_s
        to_result.inspect
      end

    end

  end

end