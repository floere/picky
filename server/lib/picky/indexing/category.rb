module Indexing
  
  class Category
    
    attr_reader :name, :indexed_as, :virtual, :tokenizer, :source
    
    # TODO Dup the options?
    #
    def initialize name, type, options = {}
      @type = type
      
      @source        = options[:source]
      
      @tokenizer     = options[:tokenizer] || Tokenizers::Index.default
      @indexer_class = options[:indexer]   || Indexers::Default
      @indexed_as    = options[:as]        || name
      @virtual       = options[:virtual]   || false # TODO What is this again?
      
      # TODO Push into Bundle.
      #
      partial    = options[:partial]    || Cacher::Partial::Default
      weights    = options[:weights]    || Cacher::Weights::Default
      similarity = options[:similarity] || Cacher::Similarity::Default
      
      @exact   = options[:exact_indexing_bundle]   || Bundle.new(:exact,   self, type, Cacher::Partial::None.new, weights, similarity)
      @partial = options[:partial_indexing_bundle] || Bundle.new(:partial, self, type, partial, weights, Cacher::Similarity::None.new)
      
      # @remove          = options[:remove]        || false
      # @filter          = options[:filter]        || true
      
      @options = options # TODO Remove?
    end
    
    # Note: Most of the time the source of the type is used.
    #
    def source
      @source || type.source
    end
    
    # TODO Move to config. Duplicate Code in indexers/field.rb.
    #
    def search_index_root
      File.join PICKY_ROOT, 'index'
    end
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
    def virtual?
      !!virtual
    end
    
  end
  
end