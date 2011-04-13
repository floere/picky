module Indexing # :nodoc:all

  # Registers the indexes held at index time, for indexing.
  #
  class Indexes

    attr_reader :indexes

    each_delegate :take_snapshot,
                  :generate_caches,
                  :backup_caches,
                  :restore_caches,
                  :check_caches,
                  :clear_caches,
                  :create_directory_structure,
                  :to => :indexes

    def initialize
      clear
    end

    def to_s
      indexes.indented_to_s
    end

    # Clears the array of indexes.
    #
    def clear
      @indexes = []
    end

    # Registers an index with the indexes.
    #
    def register index
      self.indexes << index
    end

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

    # For integration testing – indexes for the tests without forking and shouting ;)
    #
    def index_for_tests
      take_snapshot

      self.indexes.each do |an_index|
        an_index.index!
        an_index.cache!
      end
    end

    # Generate only the index for the given index:category pair.
    #
    def generate_index_only index_name, category_name = nil
      found = find index_name, category_name
      found.index! if found
    end
    # Generate only the cache for the given index:category pair.
    #
    def generate_cache_only index_name, category_name = nil
      found = find index_name, category_name
      found.generate_caches if found
    end

    # Find a given index:category pair.
    #
    def find index_name, category_name
      index_name = index_name.to_sym

      indexes.each do |index|
        next unless index.name == index_name

        return index unless category_name

        found = index.find category_name
        return found if found
      end

      raise %Q{Index "#{index_name}" not found. Possible indexes: "#{indexes.map(&:name).join('", "')}".}
    end

  end
end