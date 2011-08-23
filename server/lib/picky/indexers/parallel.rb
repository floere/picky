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

        # Index.
        #
        # TODO Extract into flush_every(100_000) do
        #
        i = 0

        # Explicitly reset the source to avoid caching trouble.
        #
        source.reset if source.respond_to?(:reset)

        # Go through each object in the source.
        #
        source.each do |object|
          id = object.id

          # This needs to be rewritten.
          #
          # Is it a good idea that not the tokenizer has control over when he gets the next text?
          #
          combined.each do |category, cache, _, tokenizer|
            tokens, _ = tokenizer.tokenize object.send(category.from).to_s
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
        combined.each do |_, _, file, _|
          timed_exclaim %Q{"#{@index_or_category.identifier}":   => #{file.path}.}
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

      #
      #
      def start_indexing_message # :nodoc:
        timed_exclaim %Q{"#{@index_or_category.identifier}": Starting parallel data preparation.}
      end
      def finish_indexing_message # :nodoc:
        timed_exclaim %Q{"#{@index_or_category.identifier}": Finished parallel data preparation.}
      end

    end

  end

end