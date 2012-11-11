module Picky

  module Splitters
    
    # Automatic Splitter.
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
        @memo    = {}
      end
      
      def split text
        segment(text).first
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