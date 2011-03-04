module Sources
  
  # Describes a database source. Needs a SELECT statement
  # (with id in it), and a file option or the options from an AR config file.
  #
  # The select statement can be as complicated as you want,
  # as long as it has an id in it and as long as it can be
  # used in a CREATE TABLE AS statement.
  # (working on that last one)
  #
  # Examples:
  #  Sources::DB.new('SELECT id, title, author, year FROM books') # Uses the config from app/db.yml by default.
  #  Sources::DB.new('SELECT id, title, author, year FROM books', file: 'app/some_db.yml')
  #  Sources::DB.new('SELECT b.id, b.title, b.author, b.publishing_year as year FROM books b INNER JOIN ON ...', file: 'app/some_db.yml')
  #  Sources::DB.new('SELECT id, title, author, year FROM books', adapter: 'mysql', host:'localhost', ...)
  #
  class DB < Base
    
    # The select statement that was passed in.
    #
    attr_reader :select_statement
    
    # The database adapter.
    #
    attr_reader :database
    
    # The database connection options that were either passed in or loaded from the given file.
    #
    attr_reader :connection_options
    
    @@traversal_id = :__picky_id
    
    def initialize select_statement, options = { file: 'app/db.yml' }
      @select_statement = select_statement
      @database         = create_database_adapter
      @options          = options
    end
    
    # Creates a database adapter for use with this source.
    def create_database_adapter # :nodoc:
      # TODO Do not use ActiveRecord directly.
      #
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
    def configure options # :nodoc:
      @connection_options = if filename = options[:file]
        File.open(File.join(PICKY_ROOT, filename)) { |file| YAML::load(file) }
      else
        options
      end
      self
    end
    
    # Connect the backend.
    #
    # Will raise unless connection options have been given.
    #
    def connect_backend
      configure @options
      raise "Database backend not configured" unless connection_options
      database.establish_connection connection_options
    end
    
    # Take a snapshot of the data.
    #
    # Uses CREATE TABLE AS with the given SELECT statement to create a snapshot of the data.
    #
    def take_snapshot index
      connect_backend
      
      origin = snapshot_table_name index
      
      on_database = database.connection
      
      on_database.execute "DROP TABLE IF EXISTS #{origin}"
      on_database.execute "CREATE TABLE #{origin} AS #{select_statement}"
      # TODO Use rename_column ASAP.
      #
      if on_database.adapter_name == "PostgreSQL"
        on_database.execute "ALTER TABLE #{origin} ADD COLUMN #{@@traversal_id} SERIAL PRIMARY KEY"
      else
        on_database.execute "ALTER TABLE #{origin} ADD COLUMN #{@@traversal_id} INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT"
      end
      
      # Execute any special queries this index needs executed.
      #
      on_database.execute index.after_indexing if index.after_indexing
    end
    
    # Counts all the entries that are used for the index.
    #
    def count index # :nodoc:
      connect_backend
      
      database.connection.select_value("SELECT COUNT(#{@@traversal_id}) FROM #{snapshot_table_name(index)}").to_i
    end
    
    #
    #
    def snapshot_table_name index # :nodoc:
      "picky_#{index.name}_index"
    end
    
    # Harvests the data to index in chunks.
    #
    def harvest index, category, &block
      connect_backend
      
      (0..count(index)).step(chunksize) do |offset|
        get_data index, category, offset, &block
      end
    end
    
    # Gets the data from the backend.
    #
    def get_data index, category, offset, &block # :nodoc:
      select_statement = harvest_statement_with_offset(index, category, offset)
      
      # TODO Rewrite ASAP.
      #
      if database.connection.adapter_name == "PostgreSQL"
        id_key   = 'id'
        text_key = category.from.to_s
        database.connection.execute(select_statement).each do |hash|
          id, text = hash.values_at id_key, text_key
          next unless text
          text.force_encoding 'utf-8' # TODO Still needed? Or move to backend?
          yield id, text
        end
      else
        database.connection.execute(select_statement).each do |id, text|
          next unless text
          text.force_encoding 'utf-8' # TODO Still needed? Or move to backend?
          yield id, text
        end
      end
    end
    
    # Builds a harvest statement for getting data to index.
    #
    # TODO Use the adapter for this.
    #
    def harvest_statement_with_offset index, category, offset # :nodoc:
      statement = harvest_statement index, category
      
      statement += statement.include?('WHERE') ? ' AND' : ' WHERE'
      
      "#{statement} st.#{@@traversal_id} > #{offset} LIMIT #{chunksize}"
    end
    
    # The harvest statement used to pull data from the snapshot table.
    #
    def harvest_statement index, category # :nodoc:
      "SELECT id, #{category.from} FROM #{snapshot_table_name(index)} st"
    end
    
    # The amount of records that are loaded each chunk.
    #
    def chunksize # :nodoc:
      # TODO Make parametrizable.
      #
      25_000
    end
    
  end
  
end