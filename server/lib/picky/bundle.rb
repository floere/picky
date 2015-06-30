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

    forward :[], :[]=,        :to => :configuration
    forward :index_directory, :to => :category

    # TODO Move the strategies into options.
    #
    def initialize name, category, weight_strategy, partial_strategy, similarity_strategy, options = {}
      @name     = name
      @category = category

      @weight_strategy     = weight_strategy
      @partial_strategy    = partial_strategy
      @similarity_strategy = similarity_strategy
      
      @hints      = options[:hints]
      @backend    = options[:backend]

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
    # TODO Move @backend_ into the backend?
    #
    def create_backends
      @backend_inverted      = backend.create_inverted self, @hints
      @backend_weights       = backend.create_weights self, @hints
      @backend_similarity    = backend.create_similarity self, @hints
      @backend_configuration = backend.create_configuration self, @hints
      @backend_realtime      = backend.create_realtime self, @hints
    end

    # Initial indexes.
    #
    # Note that if the weights strategy doesn't need to be saved,
    # the strategy itself pretends to be an index.
    #
    def initialize_backends
      on_all_indexes_call :initial
    end

    # "Empties" the index(es) by getting a new empty
    # internal backend instance.
    #
    def empty
      on_all_indexes_call :empty
    end

    # Extracted to avoid duplicate code.
    #
    def on_all_indexes_call method_name
      @inverted      = @backend_inverted.send method_name
      @weights       = @weight_strategy.respond_to?(:saved?) && !@weight_strategy.saved? ? @weight_strategy : @backend_weights.send(method_name)
      @similarity    = @backend_similarity.send method_name
      @configuration = @backend_configuration.send method_name
      @realtime      = @backend_realtime.send method_name
    end

    # Delete all index files.
    #
    def delete
      @backend_inverted.delete       if @backend_inverted.respond_to? :delete
      # THINK about this. Perhaps the strategies should implement the backend methods?
      #
      @backend_weights.delete        if @backend_weights.respond_to?(:delete) && @weight_strategy.respond_to?(:saved?) && @weight_strategy.saved?
      @backend_similarity.delete     if @backend_similarity.respond_to? :delete
      @backend_configuration.delete  if @backend_configuration.respond_to? :delete
      @backend_realtime.delete       if @backend_realtime.respond_to? :delete
    end

    # Get a list of similar texts.
    #
    # Note: Also checks for itself.
    #
    def similar str_or_sym
      code = similarity_strategy.encode str_or_sym
      return [] unless code
      @similarity[code] || []
      
      # similar_codes = @similarity[code]
      # if similar_codes.blank?
      #   [] # Return a simple array.
      # else
      #   similar_codes = similar_codes.dup
      #   similar_codes.delete text # Remove itself.
      #   similar_codes
      # end
    end

    # If a key format is set, use it, else forward to the category.
    #
    def key_format
      @key_format ||= @category.key_format
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

    def to_tree_s indent = 0, &block
      s = <<-TREE
#{' ' * indent}#{self.class.name.gsub('Picky::','')}(#{name})
#{' ' * indent}    Inverted(#{inverted.size})[#{backend_inverted}]#{block && block.call(inverted)}
#{' ' * indent}    Weights (#{weights.size})[#{backend_weights}]#{block && block.call(weights)}
#{' ' * indent}    Similari(#{similarity.size})[#{backend_similarity}]#{block && block.call(similarity)}
#{' ' * indent}    Realtime(#{realtime.size})[#{backend_realtime}]#{block && block.call(realtime)}
#{' ' * indent}    Configur(#{configuration.size})[#{backend_configuration}]#{block && block.call(configuration)}
TREE
      s.chomp
    end

    def to_s
      "#{self.class}(#{identifier})"
    end

  end
end