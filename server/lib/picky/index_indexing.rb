module Picky

  #
  #
  class Index
    include Helpers::Indexing

    forward :cache,
            :clear,
            :to => :categories

    # Define an index tokenizer on the index.
    #
    # Parameters are the exact same as for indexing.
    #
    def indexing options = {}
      @tokenizer = Tokenizer.from options
    end

    # Calling prepare on an index will call prepare
    # on every category.
    #
    # Decides whether to use a parallel indexer or whether to
    # forward to each category to prepare themselves.
    #
    # TODO Do a critical reading of this on the blog.
    #
    def prepare scheduler = Scheduler.new
      if source.respond_to?(:each)
        check_source_empty
        prepare_in_parallel scheduler
      else
        with_data_snapshot { categories.prepare scheduler }
      end
    end

    # Check if the given enumerable source is empty.
    #
    # Note: Checking as early as possible to tell the
    #       user as early as possible.
    #
    def check_source_empty
      Picky.logger.warn %Q{\n\033[1mWarning\033[m, source for index "#{name}" is empty: #{source} (responds true to empty?).\n} if source.respond_to?(:empty?) && source.empty?
    end

    # Indexes the categories in parallel.
    #
    # Only use where the category does have a #each source defined.
    #
    def prepare_in_parallel scheduler
      indexer = Indexers::Parallel.new self
      indexer.prepare categories, scheduler
    end

    # Note: Duplicated in category_indexing.rb.
    #
    # Take a data snapshot if the source offers it.
    #
    def with_data_snapshot
      if source.respond_to? :with_snapshot
        source.with_snapshot(self) do
          yield
        end
      else
        yield
      end
    end

    # Returns the installed tokenizer or the default.
    #
    def tokenizer
      @tokenizer || Indexes.tokenizer
    end

    # Define a source on the index.
    #
    # Parameter is a source, either one of the standard sources or
    # anything responding to #each and returning objects that
    # respond to id and the category names (or the category from option).
    #
    def source some_source = nil, &block
      some_source ||= block
      some_source ? (@source = Source.from(some_source, false, name)) : unblock_source
    end
    # Get the actual source if it is wrapped in a time
    # capsule, ie. a block/lambda.
    #
    def unblock_source
      @source.respond_to?(:call) ? @source.call : @source
    end

    # API method.
    #
    # Defines the name of the ID method to use on the indexed object.
    #
    # === Parameters
    # * name: Method name of the ID.
    #
    def id name = nil, options = {}
      key_format options[:format]
      @id_name = name || @id_name || :id
    end

    # Define a key_format on the index.
    #
    # Parameter is a method name to use on the key (e.g. :to_i, :to_s, :strip, :split).
    #
    # TODO Rename to id_format.
    #
    def key_format key_format = nil
      key_format ? (@key_format = key_format) : @key_format
    end

    # Define what to do after indexing.
    # (Only used in the Sources::DB)
    #
    def after_indexing after_indexing = nil
      after_indexing ? (@after_indexing = after_indexing) : @after_indexing
    end

  end

end