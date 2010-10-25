module Configuration
  
  # Describes the configuration of a "field", a category
  # (title is a category of a books index, for example).
  #
  class Field
    attr_reader :name, :indexed_name, :virtual
    attr_accessor :type # convenience
    def initialize name, options = {}
      @name            = name.to_sym
      
      # TODO Dup the options?
      
      @source          = options.delete :source
      
      @indexer_class   = options.delete(:indexer)   || Indexers::Default
      @tokenizer_class = options.delete(:tokenizer) || Tokenizers::Index # Default
      
      @indexed_name    = options.delete(:indexed_field) || name # TODO Rename to indexed_as?
      @virtual         = options.delete(:virtual)       || false
      
      qualifiers = generate_qualifiers_from options
      Query::Qualifiers.add(name, qualifiers) if qualifiers
      
      # @remove          = options[:remove]        || false
      # @filter          = options[:filter]        || true
      
      @options = options
    end
    def generate_qualifiers_from options
      options[:qualifiers] || options[:qualifier] && [options[:qualifier]] || [name]
    end
    def source
      @source || type.source
    end
    def generate
      Index::Category.new self.name, type, @options
    end
    # TODO Duplicate code in bundle. Move to application.
    #
    # TODO Move to type, and use in bundle from there.
    #
    def search_index_root
      File.join PICKY_ROOT, 'index'
    end
    # TODO Move to config. Duplicate Code in field.rb.
    #
    def cache_directory
      File.join search_index_root, PICKY_ENVIRONMENT, type.name.to_s
    end
    def search_index_file_name
      File.join cache_directory, "prepared_#{name}_index.txt"
    end
    def index
      prepare_cache_directory
      indexer.index
    end
    def prepare_cache_directory
      FileUtils.mkdir_p cache_directory
    end
    def cache
      prepare_cache_directory
      generate.generate_caches
    end
    def indexer
      @indexer || @indexer = @indexer_class.new(type, self)
    end
    def tokenizer
      @tokenizer || @tokenizer = @tokenizer_class.new
    end
    def virtual?
      !!virtual
    end
  end

end