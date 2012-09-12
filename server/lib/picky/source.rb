module Picky
  
  module Source
    extend Helpers::Identification
    
    # Either a thing responding to #each or a block is fine.
    #
    def self.from thing, nil_ok, index_name = nil
      if thing.respond_to?(:each) || thing.respond_to?(:call)
        thing
      else
        return if nil_ok
          
        raise ArgumentError.new(<<-ERROR)
The source #{identifier_for(index_name)}should respond to either the method #each or
it can be a lambda/block, returning such a source.
ERROR
      end
    end
    
  end
  
end