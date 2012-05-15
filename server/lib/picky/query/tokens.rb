module Picky

  # encoding: utf-8
  #
  module Query

    # This class primarily handles switching through similar token constellations.
    #
    class Tokens

      attr_reader :ignore_unassigned

      # Basically delegates to its internal tokens array.
      #
      self.delegate *[Enumerable.instance_methods, :slice!, :[], :uniq!, :last, :reject!, :length, :size, :empty?, :each, :exit, { :to => :@tokens }].flatten

      # Create a new Tokens object with the array of tokens passed in.
      #
      def initialize tokens, ignore_unassigned = false
        @tokens            = tokens
        @ignore_unassigned = ignore_unassigned
      end

      # Creates a new Tokens object from a number of Strings.
      #
      def self.processed words, originals, ignore_unassigned = false
        new words.zip(originals).collect! { |word, original| Token.processed word, original }, ignore_unassigned
      end

      # Generates an array in the form of
      # [
      #  [combination],                           # of token 1
      #  [combination, combination, combination], # of token 2
      #  [combination, combination]               # of token 3
      # ]
      #
      def possible_combinations_in index
        @tokens.inject([]) do |combinations, token|
          possible_combinations = token.possible_combinations_in index

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

      #
      #
      def categorize mapper
        @tokens.each { |token| token.categorize mapper }
      end

      #
      #
      def originals
        @tokens.map(&:original)
      end

      def == other
        self.tokens == other.tokens
      end

      # Just join the token original texts.
      #
      def to_s
        originals.join ' '
      end

    end

  end

end