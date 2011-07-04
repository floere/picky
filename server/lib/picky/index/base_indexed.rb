module Index

  #
  #
  class Base
    
    attr_reader :result_identifier,
                :combinator
                
    delegate :load_from_cache,
             :analyze,
             :to => :categories
             
    # Return the possible combinations for this token.
    #
    # A combination is a tuple <token, index_bundle>.
    #
    def possible_combinations token
      categories.possible_combinations_for token
    end
    
  end
  
end