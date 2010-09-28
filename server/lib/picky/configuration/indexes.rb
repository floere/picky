module Configuration

  class Indexes
    
    attr_reader :types
    
    def initialize *types
      @types = types
    end
    
    #
    #
    def default_index
      Tokenizers::Index
    end
    
    # Delegates
    #
    delegate :illegal_characters, :contract_expressions, :stopwords, :split_text_on, :normalize_words, :illegal_characters_after, :to => :default_index
    
    #
    #
    def type name, *fields
      types << Type.new(name, *fields)
    end
    def field name, options = {}
      Field.new name, options
    end
    
    #
    #
    def take_snapshot *type_names
      only_if_included_in type_names do |type|
        type.take_snapshot
      end
    end
    def index *type_names
      only_if_included_in type_names do |type|
        type.index
      end
    end
    def index_solr *type_names
      only_if_included_in type_names do |type|
        type.index_solr
      end
    end
    
    #
    #
    def only_if_included_in type_names = []
      type_names = types.map(&:name) if type_names.empty?
      types.each do |type|
        next unless type_names.include?(type.name)
        yield type
      end
    end
    
  end

end