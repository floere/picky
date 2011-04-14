# encoding: utf-8
#
module Indexers

  # Uses a number of categories, a source, and a tokenizer to index data.
  #
  # The tokenizer is taken from each category if specified, from the index, if not.
  #
  class Parallel < Base

    delegate :categories, :source, :to => :@index

    def initialize index
      @index = index
    end

    def process
      comma   = ?,
      newline = ?\n

      # Prepare a combined object - array.
      #
      combined = categories.map { |category| [category, [], category.prepared_index_file, (category.tokenizer || tokenizer)] }

      # Index.
      #
      i = 0
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
    def flush combined
      combined.each do |_, cache, file, _|
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