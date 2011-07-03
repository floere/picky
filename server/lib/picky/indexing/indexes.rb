module Indexing # :nodoc:all

  # Registers the indexes held at index time, for indexing.
  #
  class Indexes
    
    include ::Shared::Indexes

    each_delegate :take_snapshot,
                  :generate_caches,
                  :backup_caches,
                  :restore_caches,
                  :check_caches,
                  :clear_caches,
                  :create_directory_structure,
                  :to => :indexes

    # Runs the indexers in parallel (index + cache).
    #
    def index randomly = true
      take_snapshot

      # Run in parallel.
      #
      timed_exclaim "Indexing using #{Cores.max_processors} processors, in #{randomly ? 'random' : 'given'} order."

      # Run indexing/caching forked.
      #
      Cores.forked self.indexes, { randomly: randomly } do |an_index|
        an_index.index!
        an_index.cache!
      end

      timed_exclaim "Indexing finished."
    end

    # For integration testing – indexes for the tests
    # without forking and shouting ;)
    #
    def index_for_tests
      take_snapshot

      indexes.each do |an_index|
        an_index.index!
        an_index.cache!
      end
    end

  end
end