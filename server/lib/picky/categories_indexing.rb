module Picky

  class Categories

    include Helpers::Indexing

    each_delegate :cache,
                  :clear,
                  :prepare,
                  :to => :categories

    # First prepares all categories,
    # then caches all categories.
    #
    def index scheduler = Scheduler.new
      timed_indexing scheduler do
        categories.prepare scheduler
        scheduler.finish

        categories.cache scheduler
        scheduler.finish
      end
    end
  end

end