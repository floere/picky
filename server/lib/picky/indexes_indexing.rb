module Picky

  # Indexes indexing.
  #
  class Indexes

    instance_delegate :clear,
                      :index,
                      :parallel_index,
                      :tokenizer

    each_delegate :clear,
                  :index,
                  :to => :indexes

    # Runs the indexers in parallel (prepare + cache).
    #
    def index_in_parallel options = {}
      # Run in parallel.
      #
      timed_exclaim "Indexing using #{Cores.max_processors} processors, in #{options[:randomly] ? 'random' : 'given'} order."

      # Run indexing/caching forked.
      #
      Cores.forked self.indexes, options, &:index

      timed_exclaim "Indexing finished."
    end

    #
    #
    def tokenizer
      Tokenizer.index_default
    end

  end

end