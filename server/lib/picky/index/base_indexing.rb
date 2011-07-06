module Index

  #
  #
  class Base

    attr_reader :after_indexing,
                :bundle_class,
                :tokenizer

    # Delegators for indexing.
    #
    delegate :cache,
             :check_caches,
             :clear_caches,
             :backup_caches,
             :create_directory_structure,
             :restore_caches,
             :to => :categories

    # Calling index on an index will call index
    # on every category.
    #
    # Decides whether to use a parallel indexer or whether to
    # delegate to each category to index themselves.
    #
    def index
      if source.respond_to?(:each)
        check_source_empty
        index_in_parallel
      else
        connect_backend
        # TODO Should probably be
        #   with_snapshot do
        #     categories.each &:index
        #   end
        #
        # So if with_snapshot is called again from within
        # itself, it will not be taken again (since the
        # source knows its snapshot is taken).
        #
        take_snapshot
        @indexing = true
        categories.each &:index
        @indexing = false
      end
    end

    # Check if the given enumerable source is empty.
    #
    # Note: Checking as early as possible to tell the
    #       user as early as possible.
    #
    def check_source_empty
      warn %Q{\n\033[1mWarning\033[m, source for index "#{name}" is empty: #{source} (responds true to empty?).\n} if source.respond_to?(:empty?) && source.empty?
    end

    # Connect to the backend (if possible).
    #
    def connect_backend
      source.connect_backend if source.respond_to? :connect_backend
    end

    # Take a data snapshot (if possible).
    #
    # Returns if the call comes from a category and it is indexing.
    #
    # TODO This method could take a source. Then check @indexing == source.
    #
    def take_snapshot
      return if @indexing
      source.take_snapshot self if source.respond_to? :take_snapshot
    end

    # Indexes the categories in parallel.
    #
    # Only use where the category does not have a non-#each source defined.
    #
    def index_in_parallel
      indexer = Indexers::Parallel.new self
      indexer.index categories
      categories.each &:cache
    end

    # Define an index tokenizer on the index.
    #
    # Parameters are the exact same as for indexing.
    #
    def indexing options = {}
      @tokenizer = Tokenizers::Index.new options
    end
    alias define_indexing indexing

    # Define a source on the index.
    #
    # Parameter is a source, either one of the standard sources or
    # anything responding to #each and returning objects that
    # respond to id and the category names (or the category from option).
    #
    def source some_source = nil
      some_source ? define_source(some_source) : (@source || raise_no_source)
    end
    def define_source source
      @source = source
    end
    def raise_no_source
      raise NoSourceSpecifiedException.new(<<-NO_SOURCE


No source given for index #{name}. An index needs a source.
Example:
Index::Memory.new(:with_source) do
  source   Sources::CSV.new(:title, file: 'data/books.csv')
  category :title
  category :author
end

      NO_SOURCE
)
    end

    # Define a key_format on the index.
    #
    # Parameter is a method name to use on the key (e.g. :to_i, :to_s, :strip).
    #
    def key_format format = nil
      format ? define_key_format(format) : (@key_format || :to_i)
    end
    def define_key_format key_format
      @key_format = key_format
    end

  end

end