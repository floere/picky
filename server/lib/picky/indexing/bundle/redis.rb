# encoding: utf-8
#
module Indexing # :nodoc:all
  
  module Bundle
    
    # The memory version dumps its generated indexes to disk
    # (mostly JSON) to load them into memory on startup.
    #
    class Redis < Base
      
      def initialize *args
        @backend = Index::Redis.new
      end
    
    end
    
  end
end