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
      
        def initialize *processed_tokens
          @tokens = processed_tokens
        end
        
        # TODO Combine correctly.
        # TODO Uniq?
        #
        def ids bundle
          p [:or_ids, bundle]
          @tokens.inject([]) do |total, token|
            total + token.ids(bundle)
          end
        end
        
        # TODO How to combine these?
        #
        def weight bundle
          @tokens.inject(0) do |total, token|
            total + token.weight(bundle)
          end
        end
        
        # TODO Currently not possible.
        #
        def similar?
          false
        end
        
        def predefined_categories
          @tokens.inject([]) { |categories, token| categories + token.predefined_categories }
        end
        
        # Returns an array of possible combinations.
        #
        def possible_combinations_in index
          index.possible_combinations self
        end
        
        # # Generates an array in the form of
        # # [
        # #  [combination],                           # of token 1
        # #  [combination, combination, combination], # of token 2
        # #  [combination, combination]               # of token 3
        # # ]
        # #
        # def possible_combinations_in index
        #   @tokens.inject([]) do |combinations, token|
        #     possible_combinations = token.inject([]) do |total, token|
        #       total + token.possible_combinations_in(index)
        #     end
        #     
        #     # Note: Optimization for ignoring tokens that allocate to nothing and
        #     # can be ignored.
        #     # For example in a special search, where "florian" is not
        #     # mapped to any category.
        #     #
        #     if ignore_unassigned && possible_combinations.empty?
        #       combinations
        #     else
        #       combinations << possible_combinations
        #     end
        #   end.flatten # TODO Remove fudge and clean up interface.
        # end
        
        # Just join the token original texts.
        #
        def to_s
          originals.join '|'
        end
      
      end
      
    end
    
  end
  
end