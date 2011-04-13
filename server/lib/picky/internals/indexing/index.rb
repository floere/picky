# TODO Move to the API.
#
module Internals

  module Indexing

    class Index

      attr_reader :name, :source, :categories, :after_indexing, :tokenizer

      # Delegators for indexing.
      #
      delegate :connect_backend,
               :to => :source

      delegate :backup_caches,
               :cache,
               :check_caches,
               :clear_caches,
               :create_directory_structure,
               :generate_caches,
               :index,
               :restore_caches,
               :to => :categories

      def initialize name, source, options = {}
        @name   = name
        @source = source

        @after_indexing = options[:after_indexing]
        @bundle_class   = options[:indexing_bundle_class] # TODO This should actually be a fixed parameter.

        @categories = Categories.new options[:tokenizer]
      end

      # TODO Spec. Doc.
      #
      def define_category category_name, options = {}
        options = default_category_options.merge options

        new_category = Category.new category_name, self, options
        categories << new_category
        new_category
      end
      # By default, the category uses
      # * the index's source.
      # * the index's bundle type.
      #
      def default_category_options
        {
          :source => @source,
          :indexing_bundle_class => @bundle_class
        }
      end

      # Decides whether to use a parallel indexer or whether to
      # delegate to each category to index themselves.
      #
      def index
        if source.respond_to?(:each)
          warn "Warning: Source #{source} is empty." if source.respond_to?(:empty?) && source.empty?
          categories.index_parallel self, source
        else
          categories.index
        end
      end

      # Indexing.
      #
      def take_snapshot
        source.take_snapshot self unless source.respond_to? :each
      end

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