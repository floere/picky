module Picky
  module API
    module Category

      module Partial

        def extract_partial thing
          return Generators::Partial::Default unless thing

          if thing.respond_to? :each_partial
            thing
          else
            raise <<-ERROR
partial options for #{index_name}:#{name} should be either
* for example a Partial::Substring.new(from: m, to: n), Partial::Postfix.new(from: n), Partial::Infix.new(min: m, max: n) etc.
or
* an object that responds to #each_partial(str_or_sym) and yields each partial
ERROR
          end
        end

      end

    end
  end
end