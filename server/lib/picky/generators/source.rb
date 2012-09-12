module Picky

  module Generators
    
    module Source
      
      # Either a thing responding to #each or a block is fine.
      #
      def self.from thing, nil_ok, index_name = nil, category_name = nil
        if thing.respond_to?(:each) || thing.respond_to?(:call)
          thing
        else
          return if nil_ok
          
          specifics = ""
          specifics << index_name.to_s if index_name
          specifics = "for #{specifics} " unless specifics.empty?
          
          raise ArgumentError.new(<<-ERROR)
The source #{specifics}should respond to either the method #each or
it can be a lambda/block, returning such a source.
ERROR
        end
      end
      
    end
    
  end
  
end