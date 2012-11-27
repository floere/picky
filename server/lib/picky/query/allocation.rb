module Picky

  module Query
    
    # An Allocation contains an ordered list of
    # tuples (Combinations).
    # The Combinations are ordered according to the order
    # of the words in the query.
    #
    # It offers convenience methods to calculate the #ids etc.
    #
    # An Allocation is normally contained in an Allocations container.
    #
    class Allocation

      attr_reader :count,
                  :score,
                  :combinations,
                  :result_identifier

      #
      #
      def initialize index, combinations
        @combinations = combinations

        # THINK Could this be rewritten?
        #
        @result_identifier = index.result_identifier
        @backend           = index.backend
      end

      # Asks the backend for the total score and
      # adds the boosts to it.
      #
      # Note: Combinations can be empty on eg.
      # query "alan history" and category :title is
      # ignored (ie. removed).
      #
      def calculate_score weights
        @score ||= if @combinations.empty?                                                                                                     
          0 # Optimization.
        else                                                                                                                                   
          @backend.weight(@combinations) + @combinations.boost_for(weights)                                                                                                   
        end 
      end

      # Asks the backend for the (intersected) ids.
      #
      # Note: Combinations can be empty on eg.
      # query "alan history" and category :title is
      # ignored (ie. removed).
      #
      def calculate_ids amount, offset
        return [] if @combinations.empty? # Checked here to avoid checking in each backend.
        @backend.ids @combinations, amount, offset
      end

      # Ids return by default [].
      #
      def ids
        @ids ||= []
      end

      # This starts the searching process.
      #
      # Returns the calculated ids (from the offset).
      #
      # Parameters:
      #  * amount: The amount of ids to calculate.
      #  * offset: The offset to calculate them from.
      #
      def process! amount, offset
        calculated_ids = calculate_ids amount, offset
        @count = calculated_ids.size                         # cache the count before throwing away the ids
        @ids   = calculated_ids.slice!(offset, amount) || [] # slice out the relevant part
      end
      # Same as the above, but with illegal ids. Parameter added:
      #  * illegal_ids: ids to ignore.
      #
      def process_with_illegals! amount, offset, illegal_ids
        # Note: Fairly inefficient calculation since it
        # assumes the worst case that the ids contain
        # all illegal ids.
        #
        calculated_ids = calculate_ids amount + illegal_ids.size, offset
        calculated_ids = calculated_ids - illegal_ids
        @count = calculated_ids.size                         # cache the count before throwing away the ids
        @ids   = calculated_ids.slice!(offset, amount) || [] # slice out the relevant part
      end

      #
      #
      def remove categories = []
        @combinations.remove categories
      end

      # Sort highest score first.
      #
      def <=> other_allocation
         other_allocation.score <=> self.score
      end

      # Transform the allocation into result form.
      #
      def to_result
        [self.result_identifier, self.score, self.count, @combinations.to_result, self.ids] if self.count && self.count > 0
      end

      # Json representation of this allocation.
      #
      # Note: Forwards to to_result.
      #
      def to_json options = {}
        MultiJson.encode to_result, options
      end

      #
      #
      def to_s
        "Allocation(#{to_result})"
      end

    end

  end

end