class Categories

  each_delegate :cache,
                :check_caches,
                :clear_caches,
                :backup_caches,
                :restore_caches,
                :create_directory_structure,
                :to => :categories

end