module Query
  
  # The query indexes class bundles indexes given to a query.
  #
  # Example:
  #   # If you call
  #   Query::Full.new dvd_index, mp3_index, video_index
  #   
  #   # What it does is take the three given (API-) indexes and
  #   # bundle them in an index bundle.
  #
  class Indexes
    
    attr_reader :indexes
    
    def initialize *index_definitions
      @indexes = index_definitions.map &:indexed
    end

    # Returns a number of possible allocations for the given tokens.
    #
    def allocations_for tokens
      Allocations.new(indexes.inject([]) do |previous_allocations, index|
        # Expand the combinations.
        #
        possible_combinations = tokens.possible_combinations_in index
        
        # Optimization for ignoring tokens that allocate to nothing and
        # can be ignored.
        # For example in a special search, where "florian" is not
        # mapped to any category.
        #
        possible_combinations.compact!
        
        # Generate all possible combinations.
        #
        expanded_combinations = expand_combinations_from possible_combinations
        
        # If there are none, try the next allocation.
        #
        next previous_allocations unless expanded_combinations
        
        # Add the wrapped possible allocations to the ones we already have.
        #
        previous_allocations + expanded_combinations.map! do |expanded_combination|
          Combinations.new(expanded_combination).pack_into_allocation(index.result_identifier) # TODO Do not extract result_identifier. Remove pack_into_allocation.
        end
      end)
    end
    
    # This is the core of the search engine.
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
      return if possible_combinations.any?(&:empty?)
      
      # Generate the first multiplicator "with which" (well, not quite) to multiply the smallest amount of combinations.
      #
      # TODO How does this work if an element has size 0? Since below we account for size 0.
      #      Should we even continue if an element has size 0?
      #      This means one of the tokens cannot be allocated.
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
      
      return if possible_combinations.empty?
      
      possible_combinations.shift.zip *possible_combinations
    end
    
  end
  
end