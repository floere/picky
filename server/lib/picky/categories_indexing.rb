module Picky

  class Categories

    include Helpers::Indexing

    each_delegate :cache,
                  :clear,
                  :prepare,
                  :to => :categories
  end

end