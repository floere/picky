# encoding: utf-8
#
module Indexers

  # Uses a configuration (an index-category tuple), a source, and a tokenizer to index data.
  #
  # Note: It is called serial since it indexes each
  #
  # FIXME Giving the serial a category would be enough, since it already contains a configuration!
  #
  class Serial < Base

    def initialize configuration, source, tokenizer
      @configuration = configuration
      @source        = source || raise_no_source
      @tokenizer     = tokenizer
    end

    # Selects the original id (indexed id) and a column to process. The column data is called "token".
    #
    # Note: Puts together the parts first in an array, then releasing the array from time to time by joining.
    #
    def index
      indexing_message
      process
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
      @configuration.prepared_index_file do |file|
        result = []
        source.harvest(@configuration.index, @configuration.category) do |indexed_id, text|
          tokenizer.tokenize(text).each do |token_text|
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
      timed_exclaim %Q{"#{@configuration.identifier}": Starting serial indexing.}
    end

  end
end