module Picky

  # Indexes indexing.
  #
  class Indexes

    instance_delegate :index,
                      :clear,
                      :index_for_tests,
                      :tokenizer

    each_delegate :clear,
                  :to => :indexes

    # Runs the indexers in parallel (prepare + cache).
    #
    def index randomly = true
      # Run in parallel.
      #
      timed_exclaim "Indexing using #{Cores.max_processors} processors, in #{randomly ? 'random' : 'given'} order."

      # Run indexing/caching forked.
      #
      Cores.forked self.indexes, { randomly: randomly }, &:index

      timed_exclaim "Indexing finished."
    end

    # For integration testing – indexes for the tests
    # without forking and shouting ;)
    #
    # TODO Rename to #index_without_forking, or just #index.
    #
    def index_for_tests
      indexes.each(&:index)
    end

    #
    #
    def tokenizer
      Tokenizer.index_default
    end

  end

end