module Picky
  # A Bundle is a number of indexes
  # per [index, category] combination.
  #
  # At most, there are three indexes:
  # * *core* index (always used)
  # * *weights* index (always used)
  # * *similarity* index (used with similarity)
  #
  # In Picky, indexing is separated from the index
  # handling itself through a parallel structure.
  #
  # Both use methods provided by this base class, but
  # have very different goals:
  #
  # * *Indexing*::*Bundle*::*Base* is just concerned with creating index
  #   files / redis entries and providing helper functions to e.g. check
  #   the indexes.
  #
  # * *Index*::*Bundle*::*Base* is concerned with loading these index files into
  #   memory / redis and looking up search data as fast as possible.
  #
  class Bundle

    attr_reader :name,
                :category,
                :backend

    attr_accessor :inverted,
                  :weights,
                  :similarity,
                  :configuration,

                  :backend_inverted,
                  :backend_weights,
                  :backend_similarity,
                  :backend_configuration,

                  :weights_strategy,
                  :partial_strategy,
                  :similarity_strategy

    delegate :[], :[]=,        :to => :configuration
    delegate :index_directory, :to => :category

    def initialize name, category, backend, weights_strategy, partial_strategy, similarity_strategy, options = {}
      @name     = name
      @category = category

      # TODO Tidy up a bit.
      #
      @key_format = options[:key_format]
      @prepared   = Backends::Memory::Text.new category.prepared_index_path

      @weights_strategy    = weights_strategy
      @partial_strategy    = partial_strategy
      @similarity_strategy = similarity_strategy

      # Extract specific indexes from backend.
      #
      # TODO Clean up all related.
      #
      @backend_inverted      = backend.create_inverted      self
      @backend_weights       = backend.create_weights       self
      @backend_similarity    = backend.create_similarity    self
      @backend_configuration = backend.create_configuration self

      # Initial indexes.
      #
      @inverted      = @backend_inverted.initial
      @weights       = @backend_weights.initial
      @similarity    = @backend_similarity.initial
      @configuration = @backend_configuration.initial

      @realtime_mapping = {} # id -> ary of syms.  TODO Always instantiate?
    end
    def identifier
      "#{category.identifier}:#{name}"
    end

    # Get a list of similar texts.
    #
    # Note: Does not return itself.
    #
    def similar text
      code = similarity_strategy.encoded text
      similar_codes = code && @similarity[code]
      similar_codes.delete text if similar_codes
      similar_codes || []
    end

    # If a key format is set, use it, else delegate to the category.
    #
    def key_format
      @key_format || @category.key_format
    end

    # Path and partial filename of a specific subindex.
    #
    # Subindexes are:
    #  * inverted index
    #  * weights index
    #  * partial index
    #  * similarity index
    #
    # Returns just the part without subindex type,
    # if none given.
    #
    def index_path type = nil
      ::File.join index_directory, "#{category.name}_#{name}#{ "_#{type}" if type }"
    end

    # Copies the indexes to the "backup" directory.
    #
    def backup
      @backend_inverted.backup      if @backend_inverted.respond_to? :backup
      @backend_weights.backup       if @backend_weights.respond_to? :backup
      @backend_similarity.backup    if @backend_similarity.respond_to? :backup
      @backend_configuration.backup if @backend_configuration.respond_to? :backup
    end

    # Restores the indexes from the "backup" directory.
    #
    def restore
      @backend_inverted.restore       if @backend_inverted.respond_to? :restore
      @backend_weights.restore        if @backend_weights.respond_to? :restore
      @backend_similarity.restore     if @backend_similarity.respond_to? :restore
      @backend_configuration.restore  if @backend_configuration.respond_to? :restore
    end

    # Delete all index files.
    #
    def delete
      @backend_inverted.delete       if @backend_inverted.respond_to? :delete
      @backend_weights.delete        if @backend_weights.respond_to? :delete
      @backend_similarity.delete     if @backend_similarity.respond_to? :delete
      @backend_configuration.delete  if @backend_configuration.respond_to? :delete
    end

    # Alerts the user if an index is missing.
    #
    def raise_unless_cache_exists
      raise_unless_index_exists
      raise_unless_similarity_exists
    end
    # Alerts the user if one of the necessary indexes
    # (core, weights) is missing.
    #
    def raise_unless_index_exists
      if partial_strategy.saved?
        warn_if_index_small
        raise_unless_index_ok
      end
    end
    # Alerts the user if the similarity
    # index is missing (given that it's used).
    #
    def raise_unless_similarity_exists
      if similarity_strategy.saved?
        warn_if_similarity_small
        raise_unless_similarity_ok
      end
    end

    # Outputs a warning for the given cache.
    #
    def warn_cache_small what
      warn "Warning: #{what} cache for #{identifier} smaller than 16 bytes."
    end
    # Raises an appropriate error message for the given cache.
    #
    def raise_cache_missing what
      raise "Error: The #{what} cache for #{identifier} is missing."
    end

    # Warns the user if the similarity index is small.
    #
    def warn_if_similarity_small
      warn_cache_small :similarity if backend_similarity.respond_to?(:cache_small?) && backend_similarity.cache_small?
    end
    # Alerts the user if the similarity index is not there.
    #
    def raise_unless_similarity_ok
      raise_cache_missing :similarity if backend_similarity.respond_to?(:cache_ok?) && !backend_similarity.cache_ok?
    end

    # Warns the user if the core or weights indexes are small.
    #
    def warn_if_index_small
      warn_cache_small :inverted if backend_inverted.respond_to?(:cache_small?) && backend_inverted.cache_small?
      warn_cache_small :weights  if backend_weights.respond_to?(:cache_small?)  && backend_weights.cache_small?
    end
    # Alerts the user if the core or weights indexes are not there.
    #
    def raise_unless_index_ok
      raise_cache_missing :inverted if backend_inverted.respond_to?(:cache_ok?) && !backend_inverted.cache_ok?
      raise_cache_missing :weights  if backend_weights.respond_to?(:cache_ok?)  && !backend_weights.cache_ok?
    end

    def to_s
      "#{self.class}(#{identifier})"
    end

  end
end