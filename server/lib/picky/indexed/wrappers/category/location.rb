module Picky

  module Wrappers
    module Category

      module Location

        # THINK Is this the best way to do this?
        #
        def self.install_on category, grid, precision = 1
          wrapped_exact = Wrappers::Bundle::Location.new category.exact, grid: grid, precision: precision

          category.class_eval do
            define_method :exact do
              wrapped_exact
            end
            define_method :partial do
              wrapped_exact
            end
          end

        end

      end

    end
  end

end