module Picky

  class Categories

    each_delegate :remove,
                  :add,
                  :replace,
                  :replace_from,
                  :clear_realtime,
                  :build_realtime_mapping,
                  :to => :categories

  end

end