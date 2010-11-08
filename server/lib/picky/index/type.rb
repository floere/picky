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
      @categories  = categories # for each_delegate # TODO Use real Index::Categories object.
      @combinator  = Query::Combinator.new ignore_unassigned_tokens: ignore_unassigned_tokens
    end
    
    #
    #
    def possible_combinations token
      @combinator.possible_combinations_for token
    end
    
    def category name_or_category, options = {}
      category_to_be_added = Configuration::Field === name_or_category ? name_or_category.dup : Configuration::Field.new(name, options)
      generated_category = category_to_be_added.generate_with self
      combinator.add generated_category
    end
    
  end
  
end