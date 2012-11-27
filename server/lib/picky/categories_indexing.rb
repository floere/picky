module Picky

  class Categories

    include Helpers::Indexing

    each_forward :cache,
                 :clear,
                 :prepare,
                 :to => :categories
  end

end