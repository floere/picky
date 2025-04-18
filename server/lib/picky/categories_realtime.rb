module Picky
  class Categories
    each_forward :remove,
                 :add,
                 :replace,
                 :replace_from,
                 :clear_realtime,
                 :build_realtime_mapping,
                 to: :categories
  
    def update(object, _where = :unshift)
      replace object, :unshift
    end
    
  end
end
