module Index
  
  # TODO Think about using 3 instances of this in the bundle.
  #
  class Files
    
    attr_reader :name, :category, :type
    
    def initialize name, category, type
      @name       = name
      @category   = category
      @type       = type
    end
    
    # Point to category.
    #
    def search_index_root
      File.join PICKY_ROOT, 'index'
    end
    
    # TODO Duplicate code!
    #
    # TODO Use config object?
    #
    def search_index_file_name
      File.join cache_directory, "prepared_#{category.name}_index.txt"
    end
    def retrieve
      # TODO Make r:binary configurable.
      #
      File.open(search_index_file_name, 'r:binary') do |file|
        file.each_line do |line|
          yield line.split ?,, 2
        end
      end
    end
    
    # Copies the indexes to the "backup" directory.
    #
    # TODO Move to Index::Files.
    #
    def backup
      target = backup_path
      FileUtils.mkdir target unless Dir.exists?(target)
      FileUtils.cp index_cache_path,      target, :verbose => true
      FileUtils.cp similarity_cache_path, target, :verbose => true
      FileUtils.cp weights_cache_path,    target, :verbose => true
    end
    def backup_path
      File.join File.dirname(index_cache_path), 'backup'
    end
    
    # Restores the indexes from the "backup" directory.
    #
    # TODO Move to Index::Files.
    #
    def restore
      FileUtils.cp backup_file_path_of(index_cache_path), index_cache_path, :verbose => true
      FileUtils.cp backup_file_path_of(similarity_cache_path), similarity_cache_path, :verbose => true
      FileUtils.cp backup_file_path_of(weights_cache_path), weights_cache_path, :verbose => true
    end
    def backup_file_path_of path
      dir, name = File.split path
      File.join dir, 'backup', name
    end
    
    # Delete the file at path.
    #
    # TODO Move to Index::Files.
    #
    def delete path
      `rm -Rf #{path}`
    end
    # Delete all index files.
    #
    # TODO Move to Index::Files.
    #
    def delete_all
      delete index_cache_path
      delete similarity_cache_path
      delete weights_cache_path
    end
    
    # Create directory and parent directories.
    #
    # TODO Move to Index::Files.
    #
    def create_directory
      FileUtils.mkdir_p cache_directory
    end
    # TODO Move to config. Duplicate Code in field.rb.
    #
    # TODO Move to Index::Files.
    #
    def cache_directory
      File.join search_index_root, PICKY_ENVIRONMENT, type.name.to_s
    end
    
    # Generates a cache path.
    #
    # TODO Move to Index::Files.
    #
    def cache_path text
      File.join cache_directory, "#{name}_#{text}"
    end
    def index_cache_path
      cache_path "#{category.name}_index"
    end
    def similarity_cache_path
      cache_path "#{category.name}_similarity"
    end
    def weights_cache_path
      cache_path "#{category.name}_weights"
    end
    
    def load_json path
      Yajl::Parser.parse File.open("#{path}.json", 'r'), :symbolize_keys => true
    end
    def load_marshalled path
      Marshal.load File.open("#{path}.dump", 'r:binary')
    end
    
    # Saves the index in a dump file.
    #
    def dump_index index
      index.dump_to_json index_cache_path
    end
    # Note: We marshal the similarity, as the
    #       Yajl json lib cannot load symbolized
    #       values, just keys.
    #
    def dump_similarity similarity
      similarity.dump_to_marshalled similarity_cache_path
    end
    def dump_weights weights
      weights.dump_to_json weights_cache_path
    end
    
    def load_index
      load_json index_cache_path
    end
    def load_similarity
      load_marshalled similarity_cache_path
    end
    def load_weights
      load_json weights_cache_path
    end
    
    
    # # Index checking
    # #
    # # Check all index files and raise if necessary.
    # #
    # def raise_unless_cache_exists
    #   warn_cache_small :index      if cache_small?(index_cache_path)
    #   # warn_cache_small :similarity if cache_small?(similarity_cache_path)
    #   warn_cache_small :weights    if cache_small?(weights_cache_path)
    # 
    #   raise_cache_missing :index      unless cache_ok?(index_cache_path)
    #   raise_cache_missing :similarity unless cache_ok?(similarity_cache_path)
    #   raise_cache_missing :weights    unless cache_ok?(weights_cache_path)
    # end
    
    def size_of path
      `ls -l #{path} | awk '{print $5}'`.to_i
    end
    # Check if the cache files are there and do not have size 0.
    #
    def caches_ok?
      cache_ok?(index_cache_path) &&
      cache_ok?(similarity_cache_path) &&
      cache_ok?(weights_cache_path)
    end
    # Is the cache ok? I.e. larger than four in size.
    #
    def cache_ok? path
      size_of(path) > 0
    end
    def index_cache_ok?
      cache_ok? index_cache_path
    end
    def similarity_cache_ok?
      cache_ok? similarity_cache_path
    end
    def weights_cache_ok?
      cache_ok? weights_cache_path
    end
    # Is the cache small?
    #
    def cache_small? path
      size_of(path) < 16
    end
    def index_cache_small?
      cache_small? index_cache_path
    end
    def similarity_cache_small?
      cache_small? similarity_cache_path
    end
    def weights_cache_small?
      cache_small? weights_cache_path
    end
    
  end
  
end