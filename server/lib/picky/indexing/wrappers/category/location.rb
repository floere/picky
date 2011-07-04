module Internals
  module Indexing
    module Wrappers
      module Category

        module Location

          def self.install_on category, grid, precision = 1
            new_source = Sources::Wrappers::Location.new category.source, grid, precision

            category.class_eval do
              def tokenizer
                @tokenizer ||= Internals::Tokenizers::Index.new
              end
              define_method :source do
                new_source
              end
            end

          end

        end

      end
    end
  end
end