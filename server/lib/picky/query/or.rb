module Picky

  module Query
    
    class Tokens

      # This is a combination of multiple (already processed) tokens, combined using
      # the OR character, usually | (pipe).
      #
      # It pretends to be a single token and answers to all messages
      # a token would answer to.
      #
      class Or < Tokens
      
        def initialize processed_tokens
          @tokens = processed_tokens
        end
        
        # TODO
        #
        def possible_combinations categories
          combinations = @tokens.inject([]) do |result, token|
            result + token.possible_combinations(categories)
          end
          combinations.empty? && combinations || [Query::Combination::Or.new(combinations)]
        end
        
        # # Returns the token in the form
        # #   ['original:Text', 'processedtext']
        # #
        # def to_result
        #   [originals.join('|'), texts.join('|')]
        # end
        
        # # Just join the token original texts.
        # #
        # def to_s
        #   "#{self.class}(#{originals.join '|'})"
        # end
      
      end
      
    end
    
  end
  
end