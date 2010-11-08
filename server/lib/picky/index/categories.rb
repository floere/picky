module Index
  
  # TODO Since this is used exclusively for indexing, shouldn't it be reflected in the name?
  #
  class Categories
    
    attr_reader :categories
    
    each_delegate :index,
                  :generate_caches,
                  :load_from_cache,
                  :backup_caches,
                  :restore_caches,
                  :check_caches,
                  :clear_caches,
                  :create_directory_structure,
                  :to => :categories
    
    def initialize
      @categories = []
    end
    
    def << category
      categories << category
    end
    
    def find category_name
      category_name = category_name.to_sym
      
      categories.each do |category|
        next unless category.name == category_name
        return category
      end
    end
    
  end
  
end