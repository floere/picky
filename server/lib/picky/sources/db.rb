module Sources
  
  class DB < Base
    
    attr_reader :select_statement, :database, :connection_options
    
    def initialize select_statement, with_options = { :file => 'app/db.yml' }
      @select_statement = select_statement
      @database         = create_database_adapter
      configure with_options
    end
    
    # Get a configured Database backend.
    #
    # Options:
    #  Either
    #  * file => 'some/filename.yml' # With an active record configuration.
    #  Or
    #  * The configuration as a hash.
    #
    def create_database_adapter
      adapter_class = Class.new ActiveRecord::Base
      adapter_class.abstract_class = true
      adapter_class
    end
    
    # Configure the backend.
    #
    # Options:
    #  Either
    #  * file => 'some/filename.yml' # With an active record configuration.
    #  Or
    #  * The configuration as a hash.
    #
    def configure options
      @connection_options = if filename = options[:file]
        File.open(File.join(SEARCH_ROOT, filename)) { |f| YAML::load(f) }
      else
        options
      end
      self
    end
    
    # Connect the backend.
    #
    def connect_backend
      return if SEARCH_ENVIRONMENT.to_s == 'test' # TODO Unclean.
      raise "Database backend not configured" unless connection_options
      database.establish_connection connection_options
    end
    
    # Take the snapshot.
    #
    def take_snapshot type
      connect_backend
      
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
      connect_backend
      
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
    def harvest type, field
      connect_backend
      
      (0..count(type)).step(chunksize) do |offset|
        get_data(type, field, offset).each do |indexed_id, text|
          next unless text
          text.force_encoding 'utf-8' # TODO Still needed?
          yield indexed_id, text
        end
      end
    end
    
    # Override in subclasses.
    #
    def chunksize
      25_000
    end
    
    # Gets database from the backend.
    #
    def get_data type, field, offset
      database.connection.execute harvest_statement_with_offset(type, field, offset)
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
    def harvest_statement_with_offset type, field, offset
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