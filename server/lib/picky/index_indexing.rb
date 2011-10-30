module Picky

  #
  #
  class Index

    attr_reader :bundle_class

    # Delegators for indexing.
    #
    delegate :cache,
             :check,
             :clear,
             :backup,
             :restore,
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
        with_data_snapshot do
          categories.index
        end
      end
    end

    # Define an index tokenizer on the index.
    #
    # Parameters are the exact same as for indexing.
    #
    def indexing options = {}
      @tokenizer = if options.respond_to?(:tokenize)
        options
      else
        options && Tokenizer.new(options)
      end
    end
    alias define_indexing indexing

    # Check if the given enumerable source is empty.
    #
    # Note: Checking as early as possible to tell the
    #       user as early as possible.
    #
    def check_source_empty
      warn %Q{\n\033[1mWarning\033[m, source for index "#{name}" is empty: #{source} (responds true to empty?).\n} if source.respond_to?(:empty?) && source.empty?
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

    # Indexes the categories in parallel.
    #
    # Only use where the category does have a #each source defined.
    #
    def index_in_parallel
      categories.empty
      indexer = Indexers::Parallel.new self
      indexer.index categories
      categories.cache
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
      some_source ? define_source(some_source) : (@source && extract_source || raise_no_source)
    end
    # Extract the actual source if it is wrapped in a time
    # capsule, i.e. a block/lambda.
    #
    # TODO Extract into module.
    #
    def extract_source
      @source = @source.respond_to?(:call) ? @source.call : @source
    end
    def define_source source
      check_source source
      @source = source
    end
    def raise_no_source
      raise NoSourceSpecifiedException.new(<<-NO_SOURCE


No source given for index #{name}. An index needs a source.
Example:
Index.new(:with_source) do
  source   Sources::CSV.new(:title, file: 'data/books.csv')
  category :title
  category :author
end

      NO_SOURCE
)
    end
    def check_source source # :nodoc:
      raise ArgumentError.new(<<-SOURCE


The index "#{name}" should use a data source that responds to either the method #each, or the method #harvest, which yields(id, text), OR it can be a lambda/block, returning such a source.
Or it could use one of the built-in sources:
  Sources::#{(Sources.constants - [:Base, :Wrappers, :NoCSVFileGiven, :NoCouchDBGiven]).join(',
  Sources::')}


SOURCE
) unless source.respond_to?(:each) || source.respond_to?(:harvest) || source.respond_to?(:call)
    end

    # Define a key_format on the index.
    #
    # Parameter is a method name to use on the key (e.g. :to_i, :to_s, :strip).
    #
    def key_format format = nil
      format ? define_key_format(format) : @key_format
    end
    def define_key_format key_format
      @key_format = key_format
    end

    # Define what to do after indexing.
    # (Only used in the Sources::DB)
    #
    def after_indexing after_indexing = nil
      after_indexing ? define_after_indexing(after_indexing) : @after_indexing
    end
    def define_after_indexing after_indexing
      @after_indexing = after_indexing
    end

  end

end