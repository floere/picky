module Picky

  module Splitters
    
    # Automatic Splitter.
    #
    # Use as a splitter for the splits_text_on option
    # for Searches. You need to give it an index category
    # to use for the splitting.
    #
    # Example:
    #   Picky::Search.new index do
    #     searching splits_text_on: Picky::Splitters::Automatic.new(index[:name])
    #   end
    #
    # Will split most queries correctly.
    # However, has the following problems:
    #   * "cannot" is usually split as ['can', 'not']
    #   * "rainbow" is usually split as ['rain', 'bow']
    #
    # Reference: http://norvig.com/ngrams/ch14.pdf.
    #
    # Adapted from a script submitted
    # by Andy Kitchen.
    #
    class Automatic
      
      def initialize category, options = {}
        @exact        = category.exact
        @partial      = category.partial
        @with_partial = options[:partial]
        
        reset_memoization
      end
      
      # Split the given text into its most
      # likely constituents.
      #
      def split text
        result = if @with_partial
          partial_segment text
        else
          exact_segment text
        end.first
        reset_memoization
        result
      end
      
      # Reset the memoization.
      #
      def reset_memoization
        @memo = {}
      end
      
      # Return all splits of a given string.
      #
      def splits text
        l = text.length
        (0..l-1).map do |x|
          [text.slice(0,x), text.slice(x,l)]
        end
      end
      
      #
      #
      def partial_segment text
        @memo[text] ||= splits(text).inject([[], nil]) do |(current, heaviest), (head, tail)|
          tail_weight = @partial.weight tail
          segments, head_weight = exact_segment head

          weight = (head_weight && tail_weight &&
                   (head_weight + tail_weight) ||
                   tail_weight || head_weight)
          if (weight || -1) > (heaviest || 0)
            [segments + [tail], weight]
          else
            [current, heaviest]
          end
        end
      end
      
      #
      #
      def exact_segment text
        @memo[text] ||= splits(text).inject([[], nil]) do |(current, heaviest), (head, tail)|
          tail_weight = @exact.weight tail
          segments, head_weight = exact_segment head
          
          weight = (head_weight && tail_weight &&
                   (head_weight + tail_weight) ||
                   tail_weight || head_weight)
          if (weight || -1) > (heaviest || 0)
            [tail_weight ? segments + [tail] : segments, weight]
          else
            [current, heaviest]
          end
        end
      end
      
    end
    
  end
  
end