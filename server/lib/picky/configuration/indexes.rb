module Configuration
  
  # Describes the container for all index configurations.
  #
  class Indexes
    
    attr_reader :types
    
    def initialize
      @types = []
    end
    
    #
    #
    def default_tokenizer
      @default_tokenizer ||= Tokenizers::Default.new
    end
    
    # Delegates
    #
    delegate :removes_characters, :contracts_expressions, :stopwords, :splits_text_on, :normalizes_words, :removes_characters_after_splitting, :to => :default_tokenizer
    
    # TODO Rewrite all this configuration handling.
    #
    def type name, source, *fields
      new_type = Type.new name, source, *fields
      types << new_type
      ::Indexes.configuration ||= self
      
      generated = new_type.generate
      ::Indexes.add generated
      generated
    end
    def field name, options = {}
      options[:tokenizer] ||= default_tokenizer
      
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