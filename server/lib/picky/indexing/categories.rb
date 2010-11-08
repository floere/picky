module Indexing
  
  class Categories
    
    attr_reader :categories
    
    each_delegate :index,
                  :cache,
                  :generate_caches,
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
      
      raise %Q{Index category "#{category_name}" not found. Possible categories: "#{categories.map(&:name).join('", "')}".}
    end
    
  end
  
end