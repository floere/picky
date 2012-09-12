module Picky

  module Helpers
    
    module Identification
      
      def identifier_for index_name = nil, category_name = nil
        specifics = ""
        specifics << index_name.to_s if index_name
        specifics << ":#{category_name}" if category_name
        specifics = "for #{specifics} " unless specifics.empty?
      end
    
    end
    
  end

end