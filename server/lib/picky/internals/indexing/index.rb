# TODO Move to the API.
#
module Internals

  module Indexing

    class Index

      attr_reader :name, :categories, :after_indexing, :bundle_class, :tokenizer

      # Delegators for indexing.
      #
      delegate :connect_backend,
               :to => :source

      each_delegate :backup_caches,
                    :cache!,
                    :check_caches,
                    :clear_caches,
                    :create_directory_structure,
                    :generate_caches,
                    :restore_caches,
                    :to => :categories

      def initialize name, options = {}
        @name           = name
        @source         = options[:source]
        @after_indexing = options[:after_indexing]
        @bundle_class   = options[:indexing_bundle_class] # TODO This should actually be a fixed parameter.
        @tokenizer      = options[:tokenizer]

        @categories = []
      end

      # TODO Spec. Doc.
      #
      def define_category category_name, options = {}
        new_category = Category.new category_name, self, options
        new_category = yield new_category if block_given?
        categories << new_category
        new_category
      end

      # TODO Spec. Doc.
      #
      def define_indexing options = {}
        @tokenizer = Internals::Tokenizers::Index.new options
      end

      #
      #
      def define_source source
        @source = source
      end
      def source
        @source || raise_no_source
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

      #
      #
      def find category_name
        category_name = category_name.to_sym

        categories.each do |category|
          next unless category.name == category_name
          return category
        end

        raise %Q{Index category "#{category_name}" not found. Possible categories: "#{categories.map(&:name).join('", "')}".}
      end

      # Decides whether to use a parallel indexer or whether to
      # delegate to each category to index themselves.
      #
      def index!
        if source.respond_to?(:each)
          warn %Q{\n\033[1mWarning\033[m, source for index "#{name}" is empty: #{source} (responds true to empty?).\n} if source.respond_to?(:empty?) && source.empty?
          index_parallel
        else
          categories.each &:index!
        end
      end
      # Indexes the categories in parallel.
      #
      # Only use where the category does not have a non-#each source defined.
      #
      def index_parallel
        indexer = Indexers::Parallel.new self
        categories.first.prepare_index_directory # TODO Unnice.
        indexer.index
      end

      # Indexing.
      #
      # Note: If it is an each source we do not take a snapshot.
      #
      def take_snapshot
        source.take_snapshot self unless source.respond_to? :each
      end

      #
      #
      def to_s
        <<-INDEX
Indexing(#{name}):
#{"source: #{source}".indented_to_s}
#{"Categories:\n#{categories.indented_to_s}".indented_to_s}
INDEX
      end

    end

  end

end