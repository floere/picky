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
      def process categories
        comma   = ?,
        newline = ?\n

        # Prepare a combined object - array.
        #
        combined = categories.map do |category|
          [category, [], category.prepared_index_file, (category.tokenizer || tokenizer)]
        end

        # Explicitly reset the source to avoid caching trouble.
        #
        source.reset if source.respond_to?(:reset)

        # Go through each object in the source.
        #
        i = 0
        source.each do |object|
          id = object.id

          # This needs to be rewritten.
          #
          # Is it a good idea that not the tokenizer has control over when he gets the next text?
          #
          combined.each do |category, cache, _, tokenizer|
            tokens, _ = tokenizer.tokenize object.send(category.from) # Note: Originals not needed.
            tokens.each do |token_text|
              next unless token_text
              cache << id << comma << token_text << newline
            end
          end

          if i >= 100_000
            flush combined
            i = 0
          end
          i += 1
        end

        flush combined

        # Close all files.
        #
        combined.each do |_, _, file, _|
          yield file
          file.close
        end
      end

      # Flush the combined array into the file.
      #
      def flush combined # :nodoc:
        combined.each do |_, cache, file, _|
          file.write(cache.join) && cache.clear
        end
      end

    end

  end

end