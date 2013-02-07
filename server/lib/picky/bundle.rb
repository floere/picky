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

    attr_accessor :weight_strategy,
                  :partial_strategy,
                  :similarity_strategy

    forward :[],
            :[]=,
            :to => :configuration
            
    forward :index_directory,
            :to => :category
    
    forward :add,
            :configuration,
            :dump,
            :ids,
            :inverted,
            :realtime,
            :remove,
            :similarity,
            :weight,
            :weights,
            :to => :backend
    
    # TODO Move the strategies into options.
    #
    def initialize name, category, weight_strategy, partial_strategy, similarity_strategy, options = {}
      @name     = name
      @category = category

      @weight_strategy     = weight_strategy
      @partial_strategy    = partial_strategy
      @similarity_strategy = similarity_strategy

      @key_format = options.delete :key_format
      @backend    = options.delete :backend

      backend.reset self, @weight_strategy
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
    
    def empty
      backend.empty weight_strategy
    end

    # Get a list of similar texts.
    #
    # Note: Does not return itself.
    #
    def similar text
      code = similarity_strategy.encode text
      return [] unless code
      similar_codes = similarity[code]
      if similar_codes.blank?
        [] # Return a simple array.
      else
        similar_codes = similar_codes.dup
        similar_codes.delete text
        similar_codes
      end
    end

    # If a key format is set, use it, else forward to the category.
    #
    # TODO What about setting the key_format per category?
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