# encoding: utf-8
#
module Indexing # :nodoc:all
  
  module Bundle
    
    # The memory version dumps its generated indexes to disk
    # (mostly JSON) to load them into memory on startup.
    #
    class Memory < Base
      
      # We're using files for the memory backend.
      # E.g. dump writes files.
      #
      alias backend files
    
    end
    
  end
end