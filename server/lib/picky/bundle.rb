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
                  :similarity_strategy

    delegate :[], :[]=,        :to => :configuration
    delegate :index_directory, :to => :category

    def initialize name, category, backend, similarity_strategy, options = {}
      @name                = name
      @category            = category
      @similarity_strategy = similarity_strategy

      # Extract specific indexes from backend.
      #
      @backend_inverted      = backend.create_inverted      self
      @backend_weights       = backend.create_weights       self
      @backend_similarity    = backend.create_similarity    self
      @backend_configuration = backend.create_configuration self
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
    def index_path type
      ::File.join index_directory, "#{category.name}_#{name}_#{type}"
    end

    def to_s
      "#{self.class}(#{identifier})"
    end

  end
end