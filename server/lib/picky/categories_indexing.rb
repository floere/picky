class Categories
  
  each_delegate :backup_caches,
                :cache,
                :check_caches,
                :clear_caches,
                :create_directory_structure,
                :generate_caches,
                :restore_caches,
                :to => :categories
  
end