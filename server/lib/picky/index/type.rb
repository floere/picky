module Index
  
  # This class is for multiple types.
  #
  # For example, you could have types books, isbn.
  #
  class Type
    
    attr_reader :name, :result_type, :combinator
    
    def initialize name, options = {}
      @name                     = name
      
      @result_type              = options[:result_type] || name
      ignore_unassigned_tokens  = options[:ignore_unassigned_tokens] || false # TODO Move to query, somehow.
      
      @combinator  = Query::Combinator.new ignore_unassigned_tokens: ignore_unassigned_tokens
    end
    
    # TODO Spec. Doc.
    #
    def add_category name, options = {}
      combinator << Index::Category.new(name, self, options)
    end
    
    #
    #
    def possible_combinations token
      combinator.possible_combinations_for token
    end
    
  end
  
end