module Picky
  module API
    module Category

      module Weight

        def extract_weight thing
          return Generators::Weights::Default unless thing

          if thing.respond_to? :weight_for
            thing
          elsif thing.respond_to? :to_int
            Generators::Weights::Logarithmic.new thing
          else
            raise <<-ERROR
weight options for #{index_name}:#{name} should be either
* for example a Weights::Logarithmic.new, Weights::Constant.new(int = 0), Weights::Dynamic.new(&block) etc.
or
* an object that responds to #weight_for(amount_of_ids_for_token) => float
ERROR
          end
        end

      end

    end
  end
end