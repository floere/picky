module Indexing
  
  class Category
    
    attr_reader :name, :type, :indexed_as, :virtual, :tokenizer, :source, :exact, :partial
    
    # TODO Dup the options?
    #
    def initialize name, type, options = {}
      @name = name
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
      
      @exact   = options[:exact_indexing_bundle]   || Bundle.new(:exact,   self, type, similarity, Cacher::Partial::None.new, weights)
      @partial = options[:partial_indexing_bundle] || Bundle.new(:partial, self, type, Cacher::Similarity::None.new, partial, weights)
      
      # TODO Move to Query.
      #
      # @remove          = options[:remove]        || false
      # @filter          = options[:filter]        || true
      
      @options = options # TODO Remove?
    end
    
    # TODO Move to initializer?
    #
    def identifier
      @identifier ||= "#{type.name} #{name}"
    end
    
    # Note: Most of the time the source of the type is used.
    #
    def source
      @source || type.source
    end
    
    # TODO Spec.
    #
    def backup_caches
      timed_exclaim "Backing up #{identifier}."
      exact.backup
      partial.backup
    end
    def restore_caches
      timed_exclaim "Restoring #{identifier}."
      exact.restore
      partial.restore
    end
    def check_caches
      timed_exclaim "Checking #{identifier}."
      exact.raise_unless_cache_exists
      partial.raise_unless_cache_exists
    end
    def clear_caches
      timed_exclaim "Deleting #{identifier}."
      exact.delete
      partial.delete
    end
    # def create_directory_structure
    #   timed_exclaim "Creating directory structure for #{identifier}."
    #   exact.create_directory
    #   partial.create_directory
    # end
    
    # Generates all caches for this category.
    #
    def cache
      prepare_cache_directory
      generate_caches
    end
    def generate_caches
      generate_caches_from_source
      generate_partial
      generate_caches_from_memory
      dump_caches
      timed_exclaim "CACHE FINISHED #{identifier}."
    end
    def generate_caches_from_source
      exact.generate_caches_from_source
    end
    def generate_partial
      partial.generate_partial_from exact.index
    end
    def generate_caches_from_memory
      partial.generate_caches_from_memory
    end
    def dump_caches
      exact.dump
      partial.dump
    end
    
    # TODO Partially move to type. Duplicate Code in indexers/field.rb.
    #
    # TODO Use the Files object.
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
      # files.create_directory # TODO Make this possible!
      indexer.index
    end
    def prepare_cache_directory
      FileUtils.mkdir_p cache_directory
    end
    def indexer
      @indexer || @indexer = @indexer_class.new(type, self)
    end
    def virtual?
      !!virtual
    end
    
  end
  
end