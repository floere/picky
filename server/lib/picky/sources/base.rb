module Sources
  
  # Sources are where your data comes from.
  #
  # Basically, a source has 1-3 methods.
  # * harvest: Used by the indexer to gather data.
  #            Yields an indexed_id (string or integer) and a string value.
  #
  # * connect_backend: Optional, called once for each type/category pair.
  # * take_snapshot: Optional, called once for each type.
  class Base
    
    # Note: Methods listed for illustrative purposes.
    #
    
    # Called by the indexer when gathering data.
    #
    # Yields the data (id, text for id) for the given type and field.
    #
    # When implementing or overriding your own,
    # be sure to <tt>yield</tt> (or <tt>block.call</tt>) an id (as string or integer)
    # and a corresponding text for the given type symbol and
    # category symbol.
    #
    def harvest type, category
      # yields nothing
    end
    
    # Connect to the backend.
    #
    # Note: Called once per index/category combination
    #       before harvesting.
    #
    # For example, the db backend connects the db adapter.
    #
    def connect_backend
      
    end
    
    # Used to take a snapshot of your data if it is fast changing.
    # e.g. in a database, a table based on the source's select
    # statement is created.
    #
    # Note: Called before harvesting.
    #
    def take_snapshot type
      
    end
    
  end
  
end