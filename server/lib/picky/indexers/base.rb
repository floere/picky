# encoding: utf-8
module Indexers
  # Indexer.
  #
  # 1. Gets data from the original table and copies it into a "snapshot table".
  # 3. Processes the data. I.e. takes the snapshot table data words and tokenizes etc. them. Writes the result into a txt file.
  #
  class Base
    
    def initialize type, field
      @type       = type
      @field      = field
    end
    
    # Convenience method for getting the right Tokenizer.
    #
    def tokenizer
      @field.tokenizer
    end
    # Convenience methods for user subclasses.
    #
    # TODO Duplicate code in Index::Files.
    #
    def search_index_file_name
      @field.search_index_file_name
    end
    
    # Executes the specific strategy.
    #
    def index
      process
    end
    
    # Get the source where the data is taken from.
    #
    def source
      @field.source || raise_no_source
    end
    def raise_no_source
      raise NoSourceSpecifiedException.new "No source given for index:#{@type.name}, field:#{@field.name}." # TODO field.identifier
    end
    
    # Selects the original id (indexed id) and a column to process. The column data is called "token".
    #
    # Note: Puts together the parts first in an array, then releasing the array from time to time by joining.
    #
    def process
      comma   = ?,
      newline = ?\n
      
      indexing_message
      
      # TODO Move open to Index::File. 
      #
      File.open(search_index_file_name, 'w:binary') do |file|
        result = []
        source.harvest(@type, @field) do |indexed_id, text|
          tokenizer.tokenize(text).each do |token_text|
            result << indexed_id << comma << token_text << newline
          end
          file.write(result.join) && result.clear if result.size > 100_000
        end
        file.write result.join
      end
    end
    
    def indexing_message
      timed_exclaim "INDEX #{@type.name} #{@field.name}" #:#{@field.indexed_name}." # TODO field.identifier
    end
    
  end
end