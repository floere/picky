module Picky
  module Wrappers
    module Category

      module Location

        # THINK Is this the best way to do this? Maybe make this a Module and extend?
        #
        def self.wrap category, grid, precision = 1, anchor = 0.0
          wrapped_exact = Wrappers::Bundle::Location.new category.exact, grid: grid, precision: precision, anchor: anchor

          category.class_eval do

            # Uses a basic tokenizer.
            #
            def tokenizer
              @tokenizer ||= Tokenizer.new
            end

            # Both use the exact index.
            #
            # TODO Necessary to wrap?
            #
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