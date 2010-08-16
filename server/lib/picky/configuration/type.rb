module Configuration
  class Type
    attr_reader :name,
                :indexed_table_selection,
                :fields,
                :after_indexing,
                :result_type,
                :heuristics,
                :ignore_unassigned_tokens,
                :solr
    def initialize name, indexed_table_selection, *fields, options
      if Configuration::Field === options
        fields << options
        options = {}
      end

      @name                     = name
      @indexed_table_selection  = indexed_table_selection
                                  # dup, if field is reused. TODO Rewrite.
      @fields                   = fields.map { |field| field = field.dup; field.type = self; field }

      @after_indexing           = options[:after_indexing]
      @result_type              = options[:result_type] || name
      @heuristics               = options[:heuristics] || Query::Heuristics.new({})
      @ignore_unassigned_tokens = options[:ignore_unassigned_tokens] || false # TODO Move to query?
      @solr                     = options[:solr] || nil
    end
    def generate
      categories = fields.map { |field| field.generate }
      Index::Type.new name, result_type, heuristics, ignore_unassigned_tokens, *categories
    end
    def table_name
      self # FIXME UGH
    end
    def snapshot_table_name
      "#{name}_type_index"
    end
    def take_snapshot
      DB::Source.connect
      
      DB::Source.connection.execute "DROP TABLE IF EXISTS #{snapshot_table_name}"
      DB::Source.connection.execute "CREATE TABLE #{snapshot_table_name} AS #{indexed_table_selection}"
      DB::Source.connection.execute "ALTER TABLE #{snapshot_table_name} CHANGE COLUMN id indexed_id INTEGER"
      DB::Source.connection.execute "ALTER TABLE #{snapshot_table_name} ADD COLUMN id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT"
      
      # Execute any special queries this type needs executed.
      #
      DB::Source.connection.execute after_indexing if after_indexing
    end
    def index
      fields.each do |field|
        field.index
      end
    end
    def solr_fields
      solr ? fields.select { |field| !field.virtual? } : []
    end
    # TODO Delegate to Solr handler.
    #
    def index_solr
      return unless solr
      @indexer = Indexers::Solr.new self
      @indexer.index
    end
  end
end