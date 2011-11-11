# encoding: utf-8
#
module Picky

  module Indexers

    # Uses a category to index its data.
    #
    # Note: It is called serial since it indexes each category separately.
    #
    class Serial < Base

      # Harvest the data from the source, tokenize,
      # and write to an intermediate "prepared index" file.
      #
      # Parameters:
      #  * categories: An enumerable of Category-s.
      #
      def process categories
        comma   = ?,
        newline = ?\n

        categories.each do |category|

          tokenizer = category.tokenizer

          category.prepared_index_file do |file|
            result = []

            source.harvest(category) do |indexed_id, text|
              tokens, _ = tokenizer.tokenize text # Note: Originals not needed.
              tokens.each do |token_text|
                next unless token_text
                result << indexed_id << comma << token_text << newline
              end
              file.write(result.join) && result.clear if result.size > 100_000
            end

            yield file

            file.write result.join
          end

        end

      end

    end
  end

end