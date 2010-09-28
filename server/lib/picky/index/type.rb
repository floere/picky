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
    def initialize name, result_type, heuristics, ignore_unassigned_tokens, *categories
      @name                                = name
      @result_type                         = result_type # TODO Move.
      @categories                          = categories # for each_delegate
      @heuristics                          = heuristics
      @combinator                          = Query::Combinator.new @categories, :ignore_unassigned_tokens => ignore_unassigned_tokens # TODO pass this in?
    end
    
    #
    #
    def possible_combinations token
      @combinator.possible_combinations_for token
    end
    
    # TODO Move this to the query?
    #
    def score combinations
      @heuristics.score combinations
    end
    
  end
  
end