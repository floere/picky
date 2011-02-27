# encoding: utf-8
#
module Indexers
  
  # The indexer defines the control flow.
  #
  class Serial
    
    attr_accessor :tokenizer, :source
    
    def initialize configuration, source, tokenizer
      @configuration = configuration
      @source        = source || raise_no_source
      @tokenizer     = tokenizer
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
      @source.key_format || :to_i
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
    def indexing_message
      timed_exclaim "INDEX #{@configuration}" # TODO from ...
    end
    
  end
end