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
        @category     = category
        @exact        = category.exact
        @partial      = category.partial
        @with_partial = options[:partial]
        
        reset_memoization
      end
      
      # Reset the memoization.
      #
      def reset_memoization
        @exact_memo = Hash.new
        @partial_memo = Hash.new
      end
      
      # Split the given text into its most
      # likely constituents.
      #
      def split text
        segment(text, @with_partial).first
      end
      
      # Return all splits of a given string.
      #
      def splits text
        l = text.length
        (0..l-1).map do |x|
          [text.slice(0,x), text.slice(x,l)]
        end
      end
      
      def segment text, use_partial = false
        segments, score = segment_recursively text, use_partial
        segments.collect!(&:to_s) if @category.symbol_keys?
        [segments, score && score-text.size+segments.size]
      end
      
      # Segments the given text recursively.
      #
      def segment_recursively text, use_partial = false
        text = text.to_sym if @category.symbol_keys?
        (use_partial ? @partial_memo : @exact_memo)[text] ||= splits(text).inject([[], nil]) do |(current, heaviest), (head, tail)|
          tail = tail.to_sym if @category.symbol_keys?
          tail_weight = use_partial ? @partial.weight(tail) : @exact.weight(tail)
          tail_weight && tail_weight += (tail.size-1)
          
          segments, head_weight = segment_recursively head, use_partial
          
          weight = (head_weight && tail_weight &&
                   (head_weight + tail_weight) ||
                   tail_weight || head_weight)
                   
          if (weight || -1) >= (heaviest || 0)
            [tail_weight ? segments + [tail] : segments, weight]
          else
            [current, heaviest]
          end
        end
      end
      
    end
    
  end
  
end