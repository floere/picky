module Picky

  class Categories

    each_delegate :remove,
                  :add,
                  :replace,
                  :clear_realtime,
                  :build_realtime_mapping,
                  :to => :categories

  end

end