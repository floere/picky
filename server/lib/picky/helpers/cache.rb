# TODO Not used anymore? Remove.
#
module Helpers # :nodoc:all
  
  module Cache
    # This is a simple cache.
    # The store needs to be able to answer to [] and []=.
    #
    def cached store, key, &block
      # Get cached result
      #
      results = store[key]
      return results if results
      
      results = lambda(&block).call
      
      # Store results
      #
      store[key] = results
      
      results
    end
  end
  
end