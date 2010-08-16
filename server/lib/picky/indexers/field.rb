module Indexers
  # Base indexer for fields.
  #
  class Field < Base

    # Override in subclasses.
    #
    def chunksize
      25_000
    end
    
    # Base harvest statement for fields.
    #
    def harvest_statement
      "SELECT indexed_id, #{field_name} FROM #{snapshot_table} st"
    end
    
  end
end