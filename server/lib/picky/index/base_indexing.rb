module Index

  #
  #
  class Base

    attr_reader :after_indexing,
                :bundle_class,
                :tokenizer

    # Delegators for indexing.
    #
    delegate :backup_caches,
             :cache,
             :check_caches,
             :clear_caches,
             :create_directory_structure,
             :generate_caches,
             :restore_caches,
             :to => :categories

    delegate :connect_backend,
             :to => :source

    # Calling index on an index will
    #  * prepare (the data)
    #  * cache (the data)
    # on every category.
    #
    def index
      prepare
      cache
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

    # Decides whether to use a parallel indexer or whether to
    # delegate to each category to index themselves.
    #
    # TODO Rename to prepare.
    #
    def prepare
      # TODO Duplicated in category.rb def indexer.
      #
      if source.respond_to?(:each)
        warn %Q{\n\033[1mWarning\033[m, source for index "#{name}" is empty: #{source} (responds true to empty?).\n} if source.respond_to?(:empty?) && source.empty?
        index_parallel
      else
        categories.each &:prepare
      end
    end

    # Indexes the categories in parallel.
    #
    # Only use where the category does not have a non-#each source defined.
    #
    def index_parallel
      indexer = Indexers::Parallel.new self
      categories.first.prepare_index_directory # TODO Unnice. Move into indexer.
      indexer.index # TODO Pass in source, categories.
    end

    # Indexing.
    #
    # Note: If it is an each source we do not take a snapshot.
    #
    def take_snapshot
      source.take_snapshot self unless source.respond_to? :each
    end

  end

end