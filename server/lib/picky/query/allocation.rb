module Query
  # An allocation has a number of combinations:
  # [token, index] [other_token, other_index], ...
  #
  class Allocation

    attr_reader :count, :ids, :score, :combinations, :result_type
    
    #
    #
    def initialize combinations, result_type
      @combinations = combinations
      @result_type  = result_type
    end

    def hash
      @combinations.hash
    end
    def eql? other_allocation
      true # FIXME
      # @combinations.eql? other_allocation.combinations
    end

    # Scores its combinations and caches the result.
    #
    def calculate_score weights
      @score ||= @combinations.calculate_score(weights)
    end

    # Asks the combinations for the (intersected) ids.
    #
    def calculate_ids
      @combinations.ids
    end

    # This starts the searching process.
    #
    def process! amount, offset
      ids    = calculate_ids
      @count = ids.size                         # cache the count before throwing away the ids
      @ids   = ids.slice!(offset, amount) || [] # slice out the relevant part
    end

    #
    #
    def keep identifiers = [] # categories
      @combinations.keep identifiers
    end
    #
    #
    def remove identifiers = [] # categories
      @combinations.remove identifiers
    end

    # Sort highest score first.
    #
    def <=> other_allocation
       other_allocation.score <=> self.score
    end

    # Transform the allocation into result form.
    #
    def to_result
      [self.result_type, self.score, self.count, @combinations.to_result, self.ids] if self.count > 0
    end

    # Json representation of this allocation.
    #
    # Note: Delegates to to_result.
    #
    def to_json
      to_result.to_json
    end

    #
    #
    def to_s
      "Allocation: #{to_result.join(', ')}"
    end

  end
end