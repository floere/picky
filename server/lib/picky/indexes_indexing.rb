module Picky

  # Indexes indexing.
  #
  class Indexes

    extend Helpers::Indexing
    include Helpers::Indexing

    instance_forward :clear, :tokenizer

    each_forward :cache, :clear, :prepare, :to => :indexes

    # Overrides index from the helper.
    #
    def self.index scheduler = Scheduler.new
      timed_indexing scheduler do
        instance.index scheduler
      end
    end

    #
    #
    def tokenizer
      Tokenizer.indexing
    end

  end

end