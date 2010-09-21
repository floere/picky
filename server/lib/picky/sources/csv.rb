module Sources
  
  class CSV < Base
    
    attr_reader :file_name
    
    def initialize file_name, *field_names
      @file_name = file_name
      @field_names
    end
    
    # Counts all the entries that are used for the index.
    #
    def count type
      `wc -l #{file_name}`
    end
    
    # Harvests the data to index, chunked.
    #
    # Subclasses should override harvest_statement to define how their data is found.
    # Example:
    #   "SELECT indexed_id, value FROM bla_table st WHERE kind = 'bla'"
    #
    def harvest offset
      File.open file_name, 'r'
    end
    
  end
  
end