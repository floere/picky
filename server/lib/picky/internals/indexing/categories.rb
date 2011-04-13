module Internals

  module Indexing

    class Categories

      attr_reader :categories, :tokenizer

      delegate :<<, :map, :size, :zip, :to => :categories

      each_delegate :cache,
                    :generate_caches,
                    :index,
                    :backup_caches,
                    :restore_caches,
                    :check_caches,
                    :clear_caches,
                    :create_directory_structure,
                    :to => :categories

      def initialize tokenizer
        @tokenizer = tokenizer

        @categories = []
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

      # Indexes the categories in parallel.
      #
      def index_parallel index, source
        indexer = Indexers::Parallel.new index, self, source, tokenizer
        categories.first.prepare_index_directory
        indexer.index
      end

      def to_s
        categories.indented_to_s
      end

    end

  end

end