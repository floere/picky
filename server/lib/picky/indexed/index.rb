module Indexed
  
  #
  #
  class Index
    
    attr_reader :name, :result_type, :combinator, :categories
    
    delegate :load_from_cache,
             :to => :categories
    
    def initialize name, options = {}
      @name                     = name
      
      @result_type              = options[:result_type] || name
      ignore_unassigned_tokens  = options[:ignore_unassigned_tokens] || false # TODO Move to query, somehow.
      
      @categories = Categories.new ignore_unassigned_tokens: ignore_unassigned_tokens
    end
    
    # TODO Spec. Doc.
    #
    def add_category name, options = {}
      categories << Category.new(name, self, options)
    end
    
    #
    #
    def possible_combinations token
      categories.possible_combinations_for token
    end
    
  end
  
end