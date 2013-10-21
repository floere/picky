module Picky

  module Query

    # The query indexes class bundles indexes given to a query.
    #
    # Example:
    #   # If you call
    #   Search.new dvd_index, mp3_index, video_index
    #
    #   # What it does is take the three given (API-) indexes and
    #   # bundle them in an index bundle.
    #
    class Indexes
      
      forward :size, :first, :to => :@indexes
      
      attr_reader :indexes,
                  :ignored_categories,
                  :ignored_allocations,
                  :exclusive_allocations

      # Creates a new Query::Indexes.
      #
      # Its job is to generate all possible combinations.
      # Note: We cannot mix memory and redis indexes just yet.
      #
      def initialize *indexes
        Check.check_backends indexes

        @indexes = indexes
      end
      
      # Ignore the categories with the given qualifiers.
      #
      def ignore_categories *qualifiers
        @ignored_categories ||= []
        # @ignored_categories += qualifiers.map { |qualifier| @qualifier_mapper.map qualifier }.compact
        @ignored_categories += qualifiers
        @ignored_categories.uniq!
      end
      
      # Ignore the allocations with the given qualifiers.
      #
      def ignore_allocations *qualifier_arrays
        @ignored_allocations ||= []
        @ignored_allocations += qualifier_arrays #.map do |qualifier_array|
          # qualifier_array.map { |qualifier| @qualifier_mapper.map qualifier }
        # end.compact
        @ignored_allocations.uniq!
      end
      
      # Exclusively keep the allocations with the given qualifiers.
      #
      def keep_allocations *qualifier_arrays
        @exclusive_allocations ||= []
        @exclusive_allocations += qualifier_arrays #.map do |qualifier_array|
          # qualifier_array.map { |qualifier| @qualifier_mapper.map qualifier }
        # end.compact
        @exclusive_allocations.uniq!
      end

      # Returns a number of prepared (sorted, reduced etc.) allocations for the given tokens.
      #
      def prepared_allocations_for tokens, boosts = {}, amount = nil
        allocations = allocations_for tokens

        # Score the allocations using weights as bias.
        #
        # Note: Before we can sort them we need to score them.
        #
        allocations.calculate_score boosts

        # Filter the allocations – ignore/only.
        #
        allocations.keep_allocations exclusive_allocations if exclusive_allocations
        allocations.remove_allocations ignored_allocations if ignored_allocations

        # Sort the allocations.
        # (allocations are sorted according to score, highest to lowest)
        #
        # Before we can chop off unimportant allocations, we need to sort them.
        #
        allocations.sort!
        
        # allocations.remove_allocations ignored_allocations if ignored_allocations
        
        # Reduce the amount of allocations.
        #
        # Before we remove categories, we should reduce the amount of allocations.
        #
        allocations.reduce_to amount if amount

        # Remove categories from allocations.
        #
        allocations.remove_categories ignored_categories if ignored_categories

        allocations
      end
      # Returns a number of possible allocations for the given tokens.
      #
      def allocations_for tokens
        Allocations.new allocations_ary_for(tokens)
      end
      def allocations_ary_for tokens
        indexes.inject([]) do |allocations, index|
          allocations + allocation_for(tokens, index)
        end
      end
      def allocation_for tokens, index
        # Expand the combinations.
        #
        possible_combinations = tokens.possible_combinations_in index.categories

        # Generate all possible combinations.
        #
        all_possible_combinations = expand_combinations_from possible_combinations

        # Add the wrapped possible allocations to the ones we already have.
        #
        all_possible_combinations.map! do |expanded_combinations|
          Allocation.new index, Query::Combinations.new(expanded_combinations)
        end
      end

      # This is the core of the search engine. No kidding.
      #
      # Gets an array of
      # [
      #  [<combinations for token1>],
      #  [<combinations for token2>],
      #  [<combinations for token3>]
      # ]
      #
      # Generates all possible allocations of combinations.
      # [
      #  [first combination of token1, first c of t2, first c of t3],
      #  [first combination of token1, first c of t2, second c of t3]
      #  ...
      # ]
      #
      # Generates all possible combinations of array elements:
      # [1,2,3] x [a,b,c] x [k,l,m] => [[1,a,k], [1,a,l], [1,a,m], [1,b,k], [1,b,l], [1,b,m], [1,c,k], ..., [3,c,m]]
      # Note: Also calculates the weights and sorts them accordingly.
      #
      # Note: This is a heavily optimized ruby version.
      #
      # Works like this:
      # [1,2,3], [a,b,c], [k,l,m] are expanded to
      #  group mult: 1
      #  <- single mult ->
      # [1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3] = 27 elements
      #  group mult: 3
      #  <- -> s/m
      # [a,a,a,b,b,b,c,c,c,a,a,a,b,b,b,c,c,c,a,a,a,b,b,b,c,c,c] = 27 elements
      #  group mult: 9
      #  <> s/m
      # [k,l,m,k,l,m,k,l,m,k,l,m,k,l,m,k,l,m,k,l,m,k,l,m,k,l,m] = 27 elements
      #
      # It is then recombined, where
      # [
      #  [a,a,b,b,c,c]
      #  [d,e,d,e,d,e]
      # ]
      # becomes
      # [
      #  [a,d],
      #  [a,e],
      #  [b,d],
      #  [b,e],
      #  [c,d],
      #  [c,e]
      # ]
      #
      # Note: Not using transpose as it is slower.
      #
      # Returns nil if there are no combinations.
      #
      # Note: Of course I could split this method up into smaller
      #       ones, but I guess I am a bit sentimental.
      #
      def expand_combinations_from possible_combinations
        # If an element has size 0, this means one of the
        # tokens could not be allocated.
        #
        return [] if possible_combinations.any? { |possible_combination| possible_combination.empty? }

        # Generate the first multiplicator "with which" (well, not quite) to multiply the smallest amount of combinations.
        #
        single_mult = possible_combinations.inject(1) { |total, combinations| total * combinations.size }

        # Initialize a group multiplicator.
        #
        group_mult = 1

        # The expanding part to line up the combinations
        # for later combination in allocations.
        #
        possible_combinations.collect! do |combinations|

          # Get the size of the combinations of the first token.
          #
          combinations_size = combinations.size

          # Special case: If there is no combination for one of the tokens.
          #               In that case, we just use the same single mult for
          #               the next iteration.
          #               If there are combinations, we divide the single mult
          #               by the number of combinations.
          #
          single_mult /= combinations_size unless combinations_size.zero?

          # Expand each combination by the single mult:
          # [a,b,c]
          # [a,a,a,  b,b,b,  c,c,c]
          # Then, expand the result by the group mult:
          # [a,a,a,b,b,b,c,c,c,  a,a,a,b,b,b,c,c,c,  a,a,a,b,b,b,c,c,c]
          #
          combinations = combinations.inject([]) do |total, combination|
            total + Array.new(single_mult, combination)
          end * group_mult

          # Multiply the group mult by the combinations size,
          # since the next combinations' single mult is smaller
          # and we need to adjust for that.
          #
          group_mult = group_mult * combinations_size

          # Return the combinations.
          #
          combinations
        end

        return [] if possible_combinations.empty?

        possible_combinations.shift.zip *possible_combinations
      end

    end

  end

end