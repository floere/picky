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
                :category

    attr_accessor :inverted,
                  :weights,
                  :similarity,
                  :configuration,
                  :realtime,

                  :backend_inverted,
                  :backend_weights,
                  :backend_similarity,
                  :backend_configuration,
                  :backend_realtime,

                  :weight_strategy,
                  :partial_strategy,
                  :similarity_strategy

    delegate :[], :[]=,        :to => :configuration
    delegate :index_directory, :to => :category

    def initialize name, category, weight_strategy, partial_strategy, similarity_strategy, options = {}
      @name     = name
      @category = category

      @weight_strategy     = weight_strategy
      @partial_strategy    = partial_strategy
      @similarity_strategy = similarity_strategy

      @key_format = options.delete :key_format
      @backend    = options.delete :backend

      reset_backend
    end
    def identifier
      @identifier ||= :"#{category.identifier}:#{name}"
    end

    # If no specific backend has been set,
    # uses the category's backend.
    #
    def backend
      @backend || category.backend
    end

    # Initializes all necessary indexes from the backend.
    #
    def reset_backend
      create_backends
      initialize_backends
    end

    # Extract specific indexes from backend.
    #
    def create_backends
      @backend_inverted      = backend.create_inverted self
      @backend_weights       = backend.create_weights self
      @backend_similarity    = backend.create_similarity self
      @backend_configuration = backend.create_configuration self
      @backend_realtime      = backend.create_realtime self
    end

    # Initial indexes.
    #
    # Note that if the weights strategy doesn't need to be saved,
    # the strategy itself pretends to be an index.
    #
    def initialize_backends
      @inverted      = @backend_inverted.initial
      @weights       = @weight_strategy.saved? ? @backend_weights.initial : @weight_strategy
      @similarity    = @backend_similarity.initial
      @configuration = @backend_configuration.initial
      @realtime      = @backend_realtime.initial
    end

    # "Empties" the index(es) by getting a new empty
    # internal backend instance.
    #
    def empty
      @inverted = @backend_inverted.empty
      @weights = @weight_strategy.saved? ? @backend_weights.empty : @weight_strategy
      @similarity = @backend_similarity.empty
      @configuration = @backend_configuration.empty
      @realtime = @backend_realtime.empty
    end

    # Delete all index files.
    #
    def delete
      @backend_inverted.delete       if @backend_inverted.respond_to? :delete
      # THINK about this. Perhaps the strategies should implement the backend methods?
      #
      @backend_weights.delete        if @backend_weights.respond_to?(:delete) && @weight_strategy.saved?
      @backend_similarity.delete     if @backend_similarity.respond_to? :delete
      @backend_configuration.delete  if @backend_configuration.respond_to? :delete
      @backend_realtime.delete  if @backend_realtime.respond_to? :delete
    end

    # Get a list of similar texts.
    #
    # Note: Does not return itself.
    #
    def similar text
      code = similarity_strategy.encode text
      return [] unless code
      similar_codes = @similarity[code]
      if similar_codes.blank?
        [] # Return a simple array.
      else
        similar_codes = similar_codes.dup
        similar_codes.delete text
        similar_codes
      end
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

    def to_s
      "#{self.class}(#{identifier})"
    end

  end
end