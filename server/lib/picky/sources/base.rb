module Sources # :nodoc:
  
  # Sources are where your data comes from. This base class is an adapter that implements empty methods.
  #
  # A source has 1-3 methods:
  # * connect_backend: Optional, called once for each type/category pair.
  # * harvest: Used by the indexer to gather data. Yields an indexed_id (string or integer) and a string value.
  # * take_snapshot: Optional, called once for each type.
  #
  class Base
    
    # Note: Default methods do nothing.
    #
    
    # Connect to the backend.
    #
    # Note: Called once per index/category combination before harvesting.
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
    
    # Called by the indexer when gathering data.
    #
    # Yields the data (id, text for id) for the given type and category.
    #
    # When implementing or overriding your own,
    # be sure to <tt>yield</tt> (or <tt>block.call</tt>) an id (as string or integer)
    # and a corresponding text for the given type symbol and
    # category symbol.
    #
    def harvest type, category # :yields: id, text_for_id
      # This concrete implementation yields "nothing", override in subclasses.
      yield nil, nil
    end
    
  end
  
end