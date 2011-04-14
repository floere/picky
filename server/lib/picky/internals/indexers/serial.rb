# encoding: utf-8
#
module Indexers

  # Uses a category to index its data.
  #
  # Note: It is called serial since it indexes each
  #
  # FIXME Giving the serial a category would be enough, since it already contains an index!
  #
  class Serial < Base

    attr_reader :category

    delegate :source, :to => :category

    def initialize category
      @category = category
    end

    # The tokenizer used is a cached tokenizer from the category.
    #
    def tokenizer
      @tokenizer ||= category.tokenizer
    end

    def process
      comma   = ?,
      newline = ?\n

      # TODO Move open to config?
      #
      # @category.prepared_index do |file|
      #   source.harvest(@index, @category) do |indexed_id, text|
      #     tokenizer.tokenize(text).each do |token_text|
      #       next unless token_text
      #       file.buffer indexed_id << comma << token_text << newline
      #     end
      #     file.write_maybe
      #   end
      # end
      #
      local_tokenizer = tokenizer
      category.prepared_index_file do |file|
        result = []
        source.harvest(category) do |indexed_id, text|
          local_tokenizer.tokenize(text).each do |token_text|
            next unless token_text
            result << indexed_id << comma << token_text << newline
          end
          file.write(result.join) && result.clear if result.size > 100_000
        end
        file.write result.join
      end
    end
    #
    #
    def indexing_message
      timed_exclaim %Q{"#{@category.identifier}": Starting serial indexing.}
    end

  end
end