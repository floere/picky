module Indexed
  
  #
  #
  class Index
    
    attr_reader :name, :result_identifier, :combinator, :categories
    
    delegate :load_from_cache,
             :to => :categories
    
    def initialize name, options = {}
      @name                     = name
      
      @result_identifier        = options[:result_identifier] || name
      ignore_unassigned_tokens  = options[:ignore_unassigned_tokens] || false # TODO Move to query, somehow.
      
      @categories = Categories.new ignore_unassigned_tokens: ignore_unassigned_tokens
    end
    
    # TODO Doc.
    #
    def define_category category_name, options = {}
      new_category = Category.new category_name, self, options
      categories << new_category
      new_category
    end
    
    # Return the possible combinations for this token.
    #
    # A combination is a tuple <token, index_bundle>.
    #
    def possible_combinations token
      categories.possible_combinations_for token
    end
    
  end
  
end