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
      
      def initialize category
        @exact   = category.exact
        @partial = category.partial
        
        reset_memoization
      end
      
      def split text
        result = segment(text).first
        reset_memoization
        result
      end
      
      def reset_memoization
        @memo = {}
      end
      
      def splits text
        (0..text.length-1).map do |x|
          [text[0..x], text[x+1..-1]]
        end
      end

      def segment text
        @memo[text] ||= splits(text).inject([[], -1]) do |(current, heaviest), (head, tail)|
          segments, tailweight = if tail == ''
            [[], @partial.weight(head) || -1]
          else
            segment tail
          end
          headweight = @exact.weight head
          weight = headweight && tailweight &&
                   (headweight + tailweight) ||
                   headweight || tailweight
          if heaviest <= (weight || -1)
            [[head] + segments, weight]
          else
            [current, heaviest]
          end
        end
      end
      
    end
    
  end
  
end