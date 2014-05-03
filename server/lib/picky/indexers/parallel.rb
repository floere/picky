# encoding: utf-8
#
module Picky

  module Indexers

    # Uses a number of categories, a source, and a tokenizer to index data.
    #
    # The tokenizer is taken from each category if specified, from the index, if not.
    #
    class Parallel < Base

      # Process does the actual indexing.
      #
      # Parameters:
      #  * categories: An Enumerable of Category-s.
      #
      def process source_for_prepare, categories, scheduler = Scheduler.new
        # Prepare a combined object - array.
        #
        combined = categories.map do |category|
          [category, category.prepared_index_file, [], category.tokenizer]
        end

        # Go through each object in the source.
        #
        objects = []

        reset source_for_prepare

        source_for_prepare.each do |object|

          # Accumulate objects.
          #
          objects << object
          next if objects.size < 10_000

          # THINK Is it a good idea that not the tokenizer has
          # control over when he gets the next text?
          #
          combined.each do |category, file, cache, tokenizer|
            index_flush objects, file, category, cache, tokenizer
          end

          objects.clear

        end

        # Close all files.
        #
        combined.each do |category, file, cache, tokenizer|
          index_flush objects, file, category, cache, tokenizer
          yield file
          file.close
        end
      end

      def index_flush objects, file, category, cache, tokenizer
        comma   = ?,
        newline = ?\n

        # Optimized, therefore duplicate code.
        #
        id = category.id
        from = category.from
        objects.each do |object|
          tokens = object.send from
          tokens, _ = tokenizer.tokenize tokens if tokenizer # Note: Originals not needed. TODO Optimize?
          tokens.each do |token_text|
            next unless token_text
            cache << object.send(id) << comma << token_text << newline
          end
        end

        flush file, cache
      end

      def flush file, cache
        file.write(cache.join) && cache.clear
      end

    end

  end

end