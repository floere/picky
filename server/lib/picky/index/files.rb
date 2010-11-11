module Index
  
  class Files
    
    attr_reader :bundle_name, :category_name, :index_name
    attr_reader :prepared, :index, :similarity, :weights
    
    def initialize bundle_name, category_name, index_name
      @bundle_name   = bundle_name
      @category_name = category_name
      @index_name    = index_name
      
      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @prepared   = File::Text.new    "#{cache_directory}/prepared_#{category_name}_index"
      @index      = File::JSON.new    cache_path(:index)
      @similarity = File::Marshal.new cache_path(:similarity)
      @weights    = File::JSON.new    cache_path(:weights)
    end
    
    # Paths.
    #
    
    # Cache path, for File-s.
    #
    def cache_path name
      ::File.join cache_directory, "#{bundle_name}_#{category_name}_#{name}"
    end
    
    # Point to category.
    #
    def search_index_root
      ::File.join PICKY_ROOT, 'index'
    end
    
    # Create directory and parent directories.
    #
    def create_directory
      FileUtils.mkdir_p cache_directory
    end
    # TODO Move to config. Duplicate Code in field.rb.
    #
    def cache_directory
      "#{search_index_root}/#{PICKY_ENVIRONMENT}/#{index_name}"
    end
    def retrieve &block
      prepared.retrieve &block
    end
    
    # Single index/similarity/weights files delegation.
    #
    
    # Delegators.
    #
    
    # Dumping.
    #
    def dump_index index_hash
      index.dump index_hash
    end
    def dump_similarity similarity_hash
      similarity.dump similarity_hash
    end
    def dump_weights weights_hash
      weights.dump weights_hash
    end
    
    # Loading.
    #
    def load_index
      index.load
    end
    def load_similarity
      similarity.load
    end
    def load_weights
      weights.load
    end
    
    # Cache ok?
    #
    def index_cache_ok?
      index.cache_ok?
    end
    def similarity_cache_ok?
      similarity.cache_ok?
    end
    def weights_cache_ok?
      weights.cache_ok?
    end
    
    # Cache small?
    #
    def index_cache_small?
      index.cache_small?
    end
    def similarity_cache_small?
      similarity.cache_small?
    end
    def weights_cache_small?
      weights.cache_small?
    end
    
    # Copies the indexes to the "backup" directory.
    #
    def backup
      index.backup
      similarity.backup
      weights.backup
    end
    
    # Restores the indexes from the "backup" directory.
    #
    def restore
      index.restore
      similarity.restore
      weights.restore
    end
    
    
    # Delete all index files.
    #
    def delete
      index.delete
      similarity.delete
      weights.delete
    end
    
  end
  
end