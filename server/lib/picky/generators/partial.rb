module Picky

  module Generators
    
    module Partial
      extend Helpers::Identification
      
      def self.from thing, index_name = nil, category_name = nil
        return Default unless thing

        if thing.respond_to? :each_partial
          thing
        else
          raise <<-ERROR
partial options #{identifier_for(index_name, category_name)}should be either
* for example a Partial::Substring.new(from: m, to: n), Partial::Postfix.new(from: n), Partial::Infix.new(min: m, max: n) etc.
or
* an object that responds to #each_partial(str_or_sym) and yields each partial
ERROR
        end
      end
    
    end
    
  end

end