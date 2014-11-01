module Picky

  module Query

    # Container class for Allocation s.
    #
    # This class is asked by the Results class to
    # compile and process a query.
    # It then asks each Allocation to process their
    # ids and scores.
    #
    # It also offers convenience methods to access #ids
    # of its Allocation s.
    #
    class Allocations

      forward :each,
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
      def calculate_score boosts
        @allocations.each do |allocation|
          allocation.calculate_score boosts
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

      # Removes categories from allocations.
      #
      # Only those passed in are removed.
      #
      def remove_categories categories = []
        @allocations.each { |allocation| allocation.remove categories } unless categories.empty?
      end

      # Removes allocations.
      #
      # Only those passed in are removed.
      #
      # TODO Rewrite, speed up.
      #
      def remove_allocations qualifiers_array
        return if qualifiers_array.empty?
        @allocations.select! do |allocation|
          allocation_qualifiers = allocation.combinations.to_qualifiers.clustered_uniq
          next(false) if qualifiers_array.any? do |qualifiers|
            allocation_qualifiers == qualifiers
          end
          allocation
        end
      end

      # Keeps allocations.
      #
      # Only those passed in are kept.
      #
      # TODO Rewrite, speed up.
      #
      def keep_allocations qualifiers_array
        return if qualifiers_array.empty?
        @allocations.select! do |allocation|
          allocation_qualifiers = allocation.combinations.to_qualifiers.clustered_uniq
          next(true) if qualifiers_array.any? do |qualifiers|
            allocation_qualifiers == qualifiers
          end
        end
      end

      # Returns the top amount ids.
      #
      def ids amount = 20
        inject([]) do |total, allocation|
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
      def process! amount, offset = 0, terminate_early = nil, sorting = nil
        each do |allocation|
          sorting = nil if amount <= 0 # Stop sorting if the results aren't shown.
          calculated_ids = allocation.process! amount, offset, sorting
          if calculated_ids.empty?
            offset = offset - allocation.count unless offset.zero?
          else
            amount = amount - calculated_ids.size # we need less results from the following allocation
            offset = 0                            # we have already passed the offset
          end
          if terminate_early && amount <= 0
            break if terminate_early <= 0
            terminate_early -= 1
          end
        end
      end

      # Same as #process! but removes duplicate ids from results.
      #
      # Note that in the result later on an allocation won't be
      # included if it contains no ids (even in case they have been
      # eliminated by the unique constraint in this method).
      #
      # Note: Slower than #process! especially with large offsets.
      #
      def process_unique! amount, offset = 0, terminate_early = nil, sorting = nil
        unique_ids = []
        each do |allocation|
          sorting = nil if amount <= 0 # Stop sorting if the results aren't shown.
          calculated_ids = allocation.process_with_illegals! amount, 0, unique_ids, sorting
          projected_offset = offset - allocation.count
          unique_ids += calculated_ids # uniq this? <- No, slower than just leaving duplicates.
          if projected_offset <= 0
            allocation.ids.slice!(0, offset)
          end
          offset = projected_offset
          unless calculated_ids.empty?
            amount = amount - calculated_ids.size # we need less results from the following allocation
            offset = 0                            # we have already passed the offset
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

      def uniq!
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
        @allocations.map { |allocation| allocation.to_result }.compact
      end

      # Simply inspects the internal allocations.
      #
      def to_s
        to_result.inspect
      end

    end

  end

end