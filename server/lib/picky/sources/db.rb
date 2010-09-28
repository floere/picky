module Sources
  
  class DB < Base
    
    attr_reader :select_statement, :database
    
    def initialize select_statement, database_adapter
      @select_statement = select_statement
      @database         = database_adapter
    end
    
    # Take the snapshot.
    #
    def take_snapshot type
      database.connect
      
      origin = snapshot_table_name type

      database.connection.execute "DROP TABLE IF EXISTS #{origin}"
      database.connection.execute "CREATE TABLE #{origin} AS #{select_statement}"
      database.connection.execute "ALTER TABLE #{origin} CHANGE COLUMN id indexed_id INTEGER"
      database.connection.execute "ALTER TABLE #{origin} ADD COLUMN id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT"

      # Execute any special queries this type needs executed.
      #
      database.connection.execute type.after_indexing if type.after_indexing
    end
    
    # Counts all the entries that are used for the index.
    #
    def count type
      database.connection.select_value("SELECT COUNT(id) FROM #{snapshot_table_name(type)}").to_i
    end
    
    # Ok here?
    #
    def snapshot_table_name type
      "#{type.name}_type_index"
    end
    
    # Harvests the data to index, chunked.
    #
    # Subclasses should override harvest_statement to define how their data is found.
    # Example:
    #   "SELECT indexed_id, value FROM bla_table st WHERE kind = 'bla'"
    #
    def harvest type, field, offset, chunksize
      database.connect
      
      database.connection.execute harvest_statement_with_offset(type, field, offset, chunksize)
    end
    
    # Base harvest statement for dbs.
    #
    def harvest_statement type, field
      "SELECT indexed_id, #{field.name} FROM #{snapshot_table_name(type)} st"
    end
    
    # Builds a harvest statement for getting data to index.
    #
    # TODO Use the adapter for this.
    #
    def harvest_statement_with_offset type, field, offset, chunksize
      statement = harvest_statement type, field
      
      if statement.include? 'WHERE'
        statement += ' AND'
      else
        statement += ' WHERE'
      end
      
      "#{statement} st.id > #{offset} LIMIT #{chunksize}"
    end
    
  end
  
end