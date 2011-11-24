module Picky

  class Categories

    each_delegate :remove,
                  :add,
                  :replace,
                  :clear_realtime_mapping,
                  :build_realtime_mapping,
                  :to => :categories

  end

end