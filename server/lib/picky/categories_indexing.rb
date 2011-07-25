module Picky

  class Categories

    each_delegate :cache,
                  :check,
                  :clear,
                  :backup,
                  :restore,
                  :to => :categories

  end

end