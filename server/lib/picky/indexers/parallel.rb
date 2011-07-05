  # encoding: utf-8
#
module Indexers

  # Uses a number of categories, a source, and a tokenizer to index data.
  #
  # The tokenizer is taken from each category if specified, from the index, if not.
  #
  # TODO Think about this one more. It should work on an index, but also a single category.
  #
  class Parallel < Base

    attr_reader :index_or_category

    delegate :categories, :source, :to => :index_or_category

    def initialize index_or_category
      @index_or_category = index_or_category
    end

    def process # *categories
      comma   = ?,
      newline = ?\n

      # Prepare a combined object - array.
      #
      combined = categories.map { |category| [category, [], category.prepared_index_file, (category.tokenizer || tokenizer)] }

      # Index.
      #
      i = 0

      # Explicitly reset the source to avoid caching trouble.
      #
      source.reset if source.respond_to?(:reset)

      source.each do |object|
        id = object.id

        # This needs to be rewritten.
        #
        # Is it a good idea that not the tokenizer has control over when he gets the next text?
        #
        combined.each do |category, cache, _, tokenizer|
          tokenizer.tokenize(object.send(category.from).to_s).each do |token_text|
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
      combined.each { |_, _, file, _| file.close }
    end
    def flush combined # :nodoc:
      combined.each do |_, cache, file, _|
        file.write(cache.join) && cache.clear
      end
    end
    #
    #
    def indexing_message # :nodoc:
      timed_exclaim %Q{"#{@index_or_category.name}": Starting parallel indexing.}
    end

  end

end