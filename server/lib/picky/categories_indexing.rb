module Picky

  class Categories

    each_delegate :cache,
                  :clear,
                  :prepare,
                  :to => :categories

  end

end