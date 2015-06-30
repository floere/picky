module Picky

  #
  #
  class Category

    include Helpers::Indexing

    attr_reader :exact,
                :partial

    # Indexes, creates the "prepared_..." file.
    #
    def prepare scheduler = Scheduler.new
      categories = Categories.new
      categories << self
      with_data_snapshot do
        scheduler.schedule do
          indexer.prepare categories, scheduler
          nil # Note: Needed so procrastinate is happy.
        end
      end
    end

    # Generates all caches for this category.
    #
    def cache scheduler = Scheduler.new
      scheduler.schedule do
        empty
        retrieve
        dump
        nil # Note: Needed so procrastinate is happy.
      end
    end

    # Empty all the indexes.
    #
    # TODO Call clear.
    #
    def empty
      exact.empty
      partial.empty
    end

    # Take a data snapshot if the source offers it.
    #
    def with_data_snapshot
      if source.respond_to? :with_snapshot
        source.with_snapshot(@index) do
          yield
        end
      else
        yield
      end
    end

    # Retrieves the prepared index data into the indexes and
    # generates the necessary derived indexes.
    #
    def retrieve
      format = key_format?
      static = static?
      prepared.retrieve do |id, token|
        add_tokenized_token id, token, method: :<<, format: format, static: static, force_update: false
      end
    end

    # Return the key format.
    #
    # If no key_format is defined on the category
    # and the source has no key format, ask
    # the index for one.
    #
    def key_format
      @key_format ||= @index.key_format
    end
    def key_format?
      key_format
    end

    # Return the key format.
    #
    # If no key_format is defined on the category
    # and the source has no key format, ask
    # the index for one.
    #
    def id
      @id ||= @index.id
    end

    def static?
      @index.static? # || @static
    end

    # Where the data is taken from.
    #
    def from
      @from || name
    end

    # Return an appropriate source.
    #
    # If we have no explicit source, we'll check the index for one.
    #
    def source
      @source || @index.source
    end

    # The indexer is lazily generated and cached.
    #
    def indexer
      @indexer ||= source.respond_to?(:each) ? Indexers::Parallel.new(self) : Indexers::Serial.new(self)
    end

    # Returns an appropriate tokenizer.
    # If one isn't set on this category, will try the index,
    # and finally the default index tokenizer.
    #
    # Will return nil if tokenize is set to false.
    #
    def tokenizer
      @tokenizer || @index.tokenizer if @tokenize
    end

    # Clears the caches.
    #
    # THINK about the semantics of clear.
    # Is a delete even needed or is it clear+dump?
    #
    def clear
      exact.clear
      partial.clear
    end

  end

end