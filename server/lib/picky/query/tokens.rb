module Picky

  # encoding: utf-8
  #
  module Query

    # This class primarily handles switching through similar token constellations.
    #
    class Tokens
      
      attr_reader :tokens, :ignore_unassigned

      # Basically forwards to its internal tokens array.
      #
      forward *[Enumerable.instance_methods, :slice!, :[], :uniq!, :last, :reject!, :length, :size, :empty?, :each, :exit, :to => :@tokens].flatten
      each_forward :partial=,
                   :to => :@tokens

      # Create a new Tokens object with the array of tokens passed in.
      #
      def initialize tokens, ignore_unassigned = false
        @tokens            = tokens
        @ignore_unassigned = ignore_unassigned
      end

      # Creates a new Tokens object from a number of Strings.
      #
      @@or_splitting_pattern = /\|/
      @@splitter = Splitter.new @@or_splitting_pattern
      def self.processed words, originals, ignore_unassigned = false
        new(words.zip(originals).collect! do |word, original|
          w, *middle, rest = @@splitter.multi word
          if rest
            Or.new processed [w, *middle, rest], original.split(@@or_splitting_pattern)
          else
            Token.processed w, original
          end
        end, ignore_unassigned)
      end

      # Generates an array in the form of
      # [
      #  [combination],                           # of token 1
      #  [combination, combination, combination], # of token 2
      #  [combination, combination]               # of token 3
      # ]
      #
      def possible_combinations_in categories
        @tokens.inject([]) do |combinations, token|
          possible_combinations = token.possible_combinations categories
          
          # Note: Optimization for ignoring tokens that allocate to nothing and
          # can be ignored.
          # For example in a special search, where "florian" is not
          # mapped to any category.
          #
          if ignore_unassigned && possible_combinations.empty?
            combinations
          else
            combinations << possible_combinations
          end
        end
      end

      # Symbolizes each of the tokens.
      #
      def symbolize
        @tokens.each &:symbolize!
      end

      # Makes the last of the tokens partial.
      #
      def partialize_last
        @tokens.last.partial = true unless empty?
      end

      # TODO
      #
      def originals
        @tokens.map(&:original)
      end
      def original
        originals
      end
      # TODO
      #
      def texts
        @tokens.map(&:text)
      end
      
      #
      #
      def == other
        self.tokens == other.tokens
      end
      
      # Non-destructive addition.
      #
      def + other
        self.class.new (@tokens + other.tokens), (self.ignore_unassigned || other.ignore_unassigned)
      end

      # Just join the token original texts.
      #
      def to_s
        originals.join ' '
      end

    end

  end

end