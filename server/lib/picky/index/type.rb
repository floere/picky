module Index
  
  # This class is for multiple types.
  #
  # For example, you could have types books, isbn.
  #
  class Type
    
    attr_reader :name, :result_type, :categories, :combinator
    
    each_delegate :generate_caches, :load_from_cache, :to => :categories
    
    # TODO Use config
    #
    def initialize name, result_type, ignore_unassigned_tokens, *categories
      @name        = name
      @result_type = result_type # TODO Move.
      @categories  = categories # for each_delegate
      @combinator  = combinator_for categories, ignore_unassigned_tokens
    end
    def combinator_for categories, ignore_unassigned_tokens
       Query::Combinator.new @categories, ignore_unassigned_tokens: ignore_unassigned_tokens
    end
    
    #
    #
    def possible_combinations token
      @combinator.possible_combinations_for token
    end
    
  end
  
end