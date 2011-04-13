module Internals
  module Indexing
    module Wrappers
      module Category

        # A wrapper around category
        #
        class Location

          attr_reader :category
          attr_reader :grid, :precision

          delegate :configuration,
                   :exact,
                   :generate_caches,
                   :identifier,
                   :name,
                   :partial,
                   :prepare_index_directory,
                   :prepared_index_file,
                   :tokenizer,
                   :to => :category

          def initialize category, grid, precision = 1
            @category  = category
            @grid      = grid
            @precision = precision
          end

          # Wraps a source wrapper around the source.
          #
          def source
            Sources::Wrappers::Location.new category.source, grid, precision
          end

        end

      end
    end
  end
end