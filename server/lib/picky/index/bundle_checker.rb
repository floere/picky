# encoding: utf-8
#
module Index

  # Checks bundle indexes.
  #
  class BundleChecker
    
    attr_reader :bundle
    
    def initialize bundle
      @bundle = bundle
    end
    
    # Check all index files and raise if necessary.
    #
    def raise_unless_cache_exists
      warn_cache_small :index      if cache_small?(bundle.index_cache_path)
      # warn_cache_small :similarity if cache_small?(similarity_cache_path)
      warn_cache_small :weights    if cache_small?(bundle.weights_cache_path)

      raise_cache_missing :index      unless cache_ok?(bundle.index_cache_path)
      raise_cache_missing :similarity unless cache_ok?(bundle.similarity_cache_path)
      raise_cache_missing :weights    unless cache_ok?(bundle.weights_cache_path)
    end
    
    def size_of path
      `ls -l #{path} | awk '{print $5}'`.to_i
    end
    # Check if the cache files are there and do not have size 0.
    #
    def caches_ok?
      cache_ok?(bundle.index_cache_path) &&
      cache_ok?(bundle.similarity_cache_path) &&
      cache_ok?(bundle.weights_cache_path)
    end
    # Is the cache ok? I.e. larger than four in size.
    #
    def cache_ok? path
      size_of(path) > 0
    end
    # Raises an appropriate error message.
    #
    def raise_cache_missing what
      raise "#{what} cache for #{bundle.identifier} missing."
    end
    # Is the cache small?
    #
    def cache_small? path
      size_of(path) < 16
    end
    def warn_cache_small what
      puts "#{what} cache for #{bundle.identifier} smaller than 16 bytes."
    end
    
  end
  
end