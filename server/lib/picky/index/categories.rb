module Index
  
  class Categories
    
    attr_reader :categories, :category_hash, :ignore_unassigned_tokens
    
    each_delegate :load_from_cache,
                  :to => :categories
    
    def initialize options = {}
      clear
      
      @ignore_unassigned_tokens = options[:ignore_unassigned_tokens] || false
    end
    
    def clear
      @categories    = []
      @category_hash = {}
    end
    
    def << category
      categories << category
    end
    
    #
    #
    def possible_combinations_for token
      token.similar? ? similar_possible_for(token) : possible_for(token)
    end
    
    # 
    # 
    def similar_possible_for token
      # Get as many similar tokens as necessary
      #
      tokens = similar_tokens_for token
      # possible combinations
      #
      inject_possible_for tokens
    end
    def similar_tokens_for token
      text = token.text
      categories.inject([]) do |result, category|
        next_token = token
        # TODO adjust either this or the amount of similar in index
        #
        while next_token = next_token.next(category)
          result << next_token if next_token && next_token.text != text
        end
        result
      end
    end
    def inject_possible_for tokens
      tokens.inject([]) do |result, token|
        possible = possible_categories token
        result + possible_for(token, possible)
      end
    end
    
    # Returns possible Combinations for the token.
    #
    # The categories param is an optimization.
    #
    # TODO Return [RemovedCategory(token, nil)]
    #      If the search is ...
    #
    # TODO Make categories also a collection class.
    #
    # TODO Return [] if not ok, nil if needs to be removed?
    #      Somehow unnice, but…
    #
    def possible_for token, preselected_categories = nil
      possible = (preselected_categories || possible_categories(token)).map { |category| category.combination_for(token) }
      possible.compact!
      # This is an optimization to mark tokens that are ignored.
      #
      return if ignore_unassigned_tokens && possible.empty?
      possible # wrap in combinations
    end
    #
    #
    # TODO too many calls?
    #
    def possible_categories token
      user_defined_categories(token) || categories
    end
    # Returns nil if there is no user defined category, the category else.
    #
    def user_defined_categories token
      category_hash[token.user_defined_category_name]
    end
    
  end
  
end