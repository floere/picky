# Indexes indexing.
#
class Indexes

  instance_delegate :index,
                    :check_caches,
                    :clear_caches,
                    :backup_caches,
                    :restore_caches,
                    :create_directory_structure,
                    :index_for_tests

  each_delegate :check_caches,
                :clear_caches,
                :backup_caches,
                :restore_caches,
                :create_directory_structure,
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
  def index_for_tests
    indexes.each(&:index)
  end

end