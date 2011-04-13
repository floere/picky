module Internals
  module Shared

    module Category

      def index_name
        index.name
      end
      def category_name
        name
      end

      # Path and partial filename of a specific index on this category.
      #
      def index_path bundle_name, type
        "#{index_directory}/#{name}_#{bundle_name}_#{type}"
      end

      #
      #
      def prepared_index_path
        @prepared_index_path ||= "#{index_directory}/prepared_#{name}_index"
      end
      def prepared_index_file &block
        @prepared_index_file ||= Internals::Index::File::Text.new prepared_index_path
        @prepared_index_file.open_for_indexing &block
      end

      # Identifier for internal use.
      #
      def identifier
        @identifier ||= "#{index.name}:#{name}"
      end
      def to_s
        "#{index.name} #{name}"
      end

      # The index directory for this category.
      #
      def index_directory
        @index_directory ||= "#{PICKY_ROOT}/index/#{PICKY_ENVIRONMENT}/#{index.name}"
      end
      # Creates the index directory including all necessary paths above it.
      #
      def prepare_index_directory
        FileUtils.mkdir_p index_directory
      end

    end

  end
end