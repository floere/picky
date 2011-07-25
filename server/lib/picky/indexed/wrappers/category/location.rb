module Picky

  module Indexed
    module Wrappers
      module Category

        module Location

          def self.install_on category, grid, precision = 1
            wrapped_exact = Indexed::Wrappers::Bundle::Location.new category.indexed_exact, grid: grid, precision: precision

            category.class_eval do
              define_method :indexed_exact do
                wrapped_exact
              end
              define_method :indexed_partial do
                wrapped_exact
              end
            end

          end

        end

      end
    end
  end

end