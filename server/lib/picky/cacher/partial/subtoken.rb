module Cacher

  module Partial
    
    class SubtokenGenerator
      
      attr_reader :down_to, :starting_at
      
      def initialize down_to, starting_at
        @down_to, @starting_at = down_to, starting_at
        
        if @starting_at.zero?
          def each_subtoken token, &block
            token.each_subtoken @down_to, &block
          end
        else
          def each_subtoken token, &block
            token[0..@starting_at].intern.each_subtoken @down_to, &block
          end
        end
        
      end
      
    end
    
    # The subtoken partial strategy.
    #
    # If given
    # "florian"
    # will index
    # "floria"
    # "flori"
    # "flor"
    # "flo"
    # "fl"
    # "f"
    # Depending on what the given down_to value is. (Example with down_to == 1)
    #
    class Subtoken < Strategy
      
      # Down to is how far it will go down in generating the subtokens.
      #
      # Examples:
      # With :hello, and starting_at 0
      # * down to == 1: [:hello, :hell, :hel, :he, :h]
      # * down to == 4: [:hello, :hell]
      #
      # With :hello, and starting_at -1
      # * down to == 1: [:hell, :hel, :he, :h]
      # * down to == 4: [:hell]
      #
      def initialize options = {}
        down_to     = options[:down_to] || 1
        starting_at = options[:starting_at] || 0
        starting_at = starting_at - 1 unless starting_at.zero?
        @generator = SubtokenGenerator.new down_to, starting_at
      end
      def down_to
        @generator.down_to
      end
      def starting_at
        @generator.starting_at
      end
      
      # Generates a partial index from the given index.
      #
      def generate_from index
        result = {}
        
        # Generate for each key token the subtokens.
        #
        i = 0
        index.each_key do |token|
          i += 1
          if i == 5000
            puts "#{Time.now}: Generating partial tokens for token #{token}. This appears every 5000 tokens."
            i = 0
          end
          generate_for token, index, result
        end
        
        # Remove duplicate ids.
        #
        # TODO If it is unique for a subtoken, it is
        #      unique for all derived longer tokens.
        #
        result.each_value &:uniq!
        
        result
      end
      
      private
        
        # To each shortened token of :test
        # :test, :tes, :te, :t
        # add all ids of :test
        #
        # "token" here means just text.
        #
        # TODO Could be improved by appending the aforegoing ids?
        #
        def generate_for token, index, result
          @generator.each_subtoken(token) do |subtoken|
            if result[subtoken]
              result[subtoken] += index[token] # unique
            else
              result[subtoken] = index[token].dup # TODO Spec this dup
            end
          end
        end
        
    end
    
  end
  
end