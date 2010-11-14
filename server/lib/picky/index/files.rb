module Index
  
  class Files
    
    attr_reader :bundle_name
    attr_reader :prepared, :index, :similarity, :weights
    
    delegate :index_name, :category_name, :to => :@configuration
    
    def initialize bundle_name, configuration
      @bundle_name   = bundle_name
      @configuration = configuration
      
      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @prepared   = File::Text.new    configuration.prepared_index_file_name # "#{cache_directory}/prepared_#{category_name}_index"
      @index      = File::JSON.new    configuration.index_path(bundle_name, :index)
      @similarity = File::Marshal.new configuration.index_path(bundle_name, :similarity)
      @weights    = File::JSON.new    configuration.index_path(bundle_name, :weights)
    end
    
    # Delegators.
    #
    
    # Retrieving data.
    #
    def retrieve &block
      prepared.retrieve &block
    end
    
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