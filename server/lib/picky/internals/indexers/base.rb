# encoding: utf-8
#
module Indexers

  #
  #
  class Base

    attr_accessor :source, :tokenizer

    def initialize source, tokenizer
      @source     = source || raise_no_source
      @tokenizer  = tokenizer
    end

    # Raise a no source exception.
    #
    def raise_no_source
      raise NoSourceSpecifiedException.new("No source given for #{@configuration}.")
    end

    # Delegates the key format to the source.
    #
    # Default is to_i.
    #
    def key_format
      source.respond_to?(:key_format) && source.key_format || :to_i
    end

  end

end