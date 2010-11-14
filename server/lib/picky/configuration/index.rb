module Configuration
  
  # Holds the configuration for a
  # index/category combination.
  #
  # TODO Rename paths?
  #
  class Index
    
    attr_reader :index, :category
    
    def initialize index, category
      @index    = index
      @category = category
    end
    
    def index_name
      @index_name ||= index.name
    end
    def category_name
      @category_name ||= category.name
    end
    
    #
    #
    def index_path bundle_name, name
      "#{index_directory}/#{category_name}_#{bundle_name}_#{name}"
    end
    
    # Was: search_index_file_name
    #
    def prepared_index_file_name
      @prepared_index_file_name ||= "#{index_directory}/prepared_#{category_name}_index.txt"
    end
    
    # def file_name
    #   @file_name ||= "#{@index_name}_#{@category_name}"
    # end
    
    def identifier
      @identifier ||= "#{index_name} #{category_name}"
    end
    
    def self.index_root
      @index_root ||= "#{PICKY_ROOT}/index"
    end
    def index_root
      self.class.index_root
    end
    # Was: cache_directory
    #
    def index_directory
      @index_directory ||= "#{index_root}/#{PICKY_ENVIRONMENT}/#{index_name}"
    end
    # Was: prepare_cache_directory
    #
    def prepare_index_directory
      FileUtils.mkdir_p index_directory
    end
    
  end
  
end