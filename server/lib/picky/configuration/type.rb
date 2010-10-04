module Configuration
  class Type
    attr_reader :name,
                :source,
                :fields,
                :after_indexing,
                :result_type,
                :ignore_unassigned_tokens,
                :solr
    def initialize name, source, *fields, options
      if Configuration::Field === options
        fields << options
        options = {}
      end
      
      @name                     = name
      @source                   = source
                                  # dup, if field is reused. TODO Rewrite.
      @fields                   = fields.map { |field| field = field.dup; field.type = self; field }
      
      @after_indexing           = options[:after_indexing]
      @result_type              = options[:result_type] || name
      @ignore_unassigned_tokens = options[:ignore_unassigned_tokens] || false       # TODO Move to query?
      @solr                     = options[:solr] || nil
    end
    def generate
      categories = fields.map { |field| field.generate }
      Index::Type.new name, result_type, ignore_unassigned_tokens, *categories
    end
    def take_snapshot
      source.take_snapshot self
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
    # TODO Spec!
    #
    def connect_backend
      @source.connect_backend
    end
  end
end