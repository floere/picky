module Picky

  class Categories

    each_delegate :remove,
                  :add,
                  :replace,
                  :to => :categories

  end

end