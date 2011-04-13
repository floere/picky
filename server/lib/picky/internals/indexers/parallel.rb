# encoding: utf-8
#
module Indexers

  # Uses a number of categories, a source, and a tokenizer to index data.
  #
  # The tokenizer is taken from each category.
  #
  class Parallel < Base

    attr_accessor :index, :categories

    def initialize index, categories, source, tokenizer
      @index      = index
      @categories = categories
      super source, tokenizer
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

      # Open some files.
      #
      files = categories.map &:prepared_index_file

      # Prepare the methods.
      #
      caches            = [[]]*categories.size
      categories_caches = categories.zip caches

      # Index.
      #
      i = 0
      source.each do |object|
        id = object.id

        # This needs to be rewritten.
        #
        categories_caches.each do |category, cache|
          (tokenizer || category.tokenizer).tokenize(object.send(category.from)).each do |token_text|
            next unless token_text
            cache << id << comma << token_text << newline
          end
        end

        if i > 10_000
          flush files, caches
          i = 0
        end
        i += 1
      end
      flush files, caches
      files.each &:close
    end
    def flush files, caches
      files.zip(caches).each do |file, cache|
        file.write(cache.join) && cache.clear
      end
    end
    #
    #
    def indexing_message
      timed_exclaim %Q{"#{@index.name}": Starting parallel indexing.}
    end

  end

end