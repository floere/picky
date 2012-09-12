module Picky

  module Generators

    module Weights
      extend Helpers::Identification
      
      # Factory method to return a fitting
      # weight handling thing for the given thing.
      #  
      def self.from thing, index_name = nil, category_name = nil
        return Default unless thing

        if thing.respond_to? :weight_for
          thing
        elsif thing.respond_to? :to_int
          Logarithmic.new thing
        else
          raise <<-ERROR
weight options #{identifier_for(index_name, category_name)}should be either
* for example a Weights::Logarithmic.new, Weights::Constant.new(int = 0), Weights::Dynamic.new(&block) etc.
or
* an object that responds to #weight_for(amount_of_ids_for_token) => float
ERROR
        end
      end

    end
    
  end
  
end