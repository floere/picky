module Picky

  class Categories

    each_delegate :cache,
                  :clear,
                  :to => :categories

  end

end