# encoding: utf-8
#
module Internals

  module Indexing # :nodoc:all
  
    module Bundle
    
      # The memory version dumps its generated indexes to disk
      # (mostly JSON) to load them into memory on startup.
      #
      class Redis < Base
      
        attr_reader :backend
      
        def initialize name, configuration, *args
          super name, configuration, *args
        
          @backend = ::Index::Redis.new name, configuration # TODO Needed?
        end
    
      end
    
    end
  
  end
  
end