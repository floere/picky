module Indexers
  # Base indexer for fields.
  #
  class Field < Base

    # Override in subclasses.
    #
    def chunksize
      25_000
    end
    
  end
end