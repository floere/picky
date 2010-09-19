# encoding: utf-8
#
module Query

  # This class primarily handles switching through similar token constellations.
  #
  class Tokens

    #
    #
    cattr_accessor :maximum
    self.maximum = 5

    # Basically delegates to its internal tokens array.
    #
    self.delegate *[Enumerable.instance_methods, :slice!, :[], :uniq!, :last, :reject!, :length, :size, :empty?, :each, :exit, { :to => :@tokens }].flatten

    #
    #
    def initialize tokens = []
      @tokens = tokens
    end

    #
    #
    def tokenize_with tokenizer
      @tokens.each { |token| token.tokenize_with(tokenizer) }
    end

    # Generates an array in the form of
    # [
    #  [combination],                           # of token 1
    #  [combination, combination, combination], # of token 2
    #  [combination, combination]               # of token 3
    # ]
    #
    # TODO If we want token behaviour defined per Query, we can
    #      compact! here
    #
    def possible_combinations_in type
      @tokens.inject([]) do |combinations, token|
        combinations << token.possible_combinations_in(type)
      end
      # TODO compact! if ignore_unassigned_tokens
    end

    # Makes the last of the tokens partial.
    #
    def partialize_last
      @tokens.last.partial = true unless empty?
    end

    # Caps the tokens to the maximum.
    #
    # TODO parametrize?
    #
    def cap
      @tokens.slice!(@@maximum..-1) if cap?
    end
    def cap?
      @tokens.size > @@maximum
    end

    # Rejects blank tokens.
    #
    def reject
      @tokens.reject! &:blank?
    end

    # Switches the tokens
    #
    # TODO
    #
    def next_similar
      @tokens.first.next_similar unless empty?
    end

    # Returns a solr query.
    #
    def to_solr_query
      @tokens.map(&:to_solr).join ' '
    end

    #
    #
    def originals
      @tokens.map(&:original)
    end

    # Just join the token original texts.
    #
    def to_s
      originals.join ' '
    end
    
    def to_a
      @tokens
    end

  end

end