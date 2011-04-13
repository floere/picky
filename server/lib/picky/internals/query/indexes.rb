module Internals

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

      attr_reader :indexes

      # Creates a new Query::Indexes.
      #
      # Its job is to generate all possible combinations.
      # Note: We cannot mix memory and redis indexes just yet.
      #
      def initialize *index_definitions, combinations_type
        @combinations_type = combinations_type
        @indexes           = index_definitions.map(&:internal_indexed)
      end

      # Returns a number of prepared (sorted, reduced etc.) allocations for the given tokens.
      #
      def prepared_allocations_for tokens, weights = {}
        allocations = allocations_for tokens

        # Remove double allocations.
        #
        allocations.uniq

        # Score the allocations using weights as bias.
        #
        allocations.calculate_score weights

        # Sort the allocations.
        # (allocations are sorted according to score, highest to lowest)
        #
        allocations.sort!

        # Reduce the amount of allocations.
        #
        # allocations.reduce_to some_amount

        # Remove identifiers from allocations.
        #
        # allocations.remove some_array_of_identifiers_to_remove

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
        possible_combinations = tokens.possible_combinations_in index

        # Generate all possible combinations.
        #
        expanded_combinations = expand_combinations_from possible_combinations

        # Add the wrapped possible allocations to the ones we already have.
        #
        expanded_combinations.map! do |expanded_combination|
          Allocation.new @combinations_type.new(expanded_combination), index.result_identifier # TODO Do not extract result_identifier.
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
        return [] if possible_combinations.any?(&:empty?)

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