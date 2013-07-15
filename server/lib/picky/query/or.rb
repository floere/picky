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
        
        # TODO Combine correctly.
        # TODO Uniq?
        #
        def ids bundle
          @tokens.inject([]) do |total, token|
            total + token.ids(bundle)
          end.uniq
        end
        
        # TODO How to combine these?
        #
        def weight bundle
          @tokens.inject(nil) do |sum, token|
            weight = token.weight bundle
            weight && (weight + (sum || 0)) || sum
          end
        end
        
        # TODO Currently not possible.
        #
        def similar?
          false
        end
        def partial?
          @tokens.all?(&:partial?)
        end
        def range
          nil
        end
        
        # TODO Clean and rewrite!
        # TODO Remove uniq?
        #
        def predefined_categories mapper
          r = @tokens.inject([]) do |categories, token|
            if predefined = token.predefined_categories(mapper)
              categories + predefined
            else
              categories
            end
          end.uniq
          r = r.empty? ? nil : r
          r
        end
        
        # Returns an array of possible combinations.
        #
        def possible_combinations_in index
          index.possible_combinations self
        end
        
        # Returns the token in the form
        #   ['original:Text', 'processedtext']
        #
        def to_result
          [originals.join('|'), texts.join('|')]
        end
        
        # Just join the token original texts.
        #
        def to_s
          originals.join '|'
        end
      
      end
      
    end
    
  end
  
end