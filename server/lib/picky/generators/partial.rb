module Picky

  module Generators
    
    module Partial
      
      def self.from thing, index_name = nil, category_name = nil
        return Default unless thing

        if thing.respond_to? :each_partial
          thing
        else
          specifics = ""
          specifics << index_name if index_name
          specifics << ":#{category_name}" if category_name
          specifics = "for #{specifics} " unless specifics.empty?
          raise <<-ERROR
partial options #{specifics}should be either
* for example a Partial::Substring.new(from: m, to: n), Partial::Postfix.new(from: n), Partial::Infix.new(min: m, max: n) etc.
or
* an object that responds to #each_partial(str_or_sym) and yields each partial
ERROR
        end
      end
    
    end
    
  end

end