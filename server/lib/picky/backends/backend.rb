module Picky

  module Backends

    #
    #
    class Backend
      
      # Get the ids for the given symbol.
      #
      # Returns a (potentially empty) array of ids.
      #
      # Note: If the backend wants to return a special
      # enumerable, the backend should do so.
      #
      def ids sym_or_string
        @inverted[sym_or_string] || []
        # THINK Place the key_format conversion here – or move into the backend?
        #
        # if @key_format
        #   class << self
        #     def ids
        #       (@inverted[sym_or_string] || []).map &@key_format
        #     end
        #   end
        # else
        #   class << self
        #     def ids
        #       @inverted[sym_or_string] || []
        #     end
        #   end
        # end
      end

      # Get a weight for the given symbol.
      #
      # Returns a number, or nil.
      #
      def weight sym_or_string
        @weights[sym_or_string]
      end

      # Get settings for this bundle.
      #
      # Returns an object.
      #
      def [] sym_or_string
        @configuration[sym_or_string]
      end
      
      # TODO Push the weight strategy into the weights backend?
      #
      def reset bundle, weight_strategy
        create bundle
        init weight_strategy
      end

      # Extract specific indexes from backend.
      #
      def create bundle
        @backend_inverted      = create_inverted bundle
        @backend_weights       = create_weights bundle
        @backend_similarity    = create_similarity bundle
        @backend_configuration = create_configuration bundle
        @backend_realtime      = create_realtime bundle
      end

      # Initial indexes.
      #
      # Note that if the weights strategy doesn't need to be saved,
      # the strategy itself pretends to be an index.
      #
      def init weight_strategy
        on_all_indexes_call :initial, weight_strategy
      end

      # "Empties" the index(es) by getting a new empty
      # internal backend instance.
      #
      def empty weight_strategy
        on_all_indexes_call :empty, weight_strategy
      end
    
      # Extracted to avoid duplicate code.
      #
      def on_all_indexes_call method_name, weight_strategy
        @inverted      = @backend_inverted.send method_name
        @weights       = weight_strategy.respond_to?(:saved?) && !weight_strategy.saved? ? weight_strategy : @backend_weights.send(method_name)
        @similarity    = @backend_similarity.send method_name
        @configuration = @backend_configuration.send method_name
        @realtime      = @backend_realtime.send method_name
      end
      
      # Delete all index files.
      #
      def delete
        @backend_inverted.delete      if @backend_inverted.respond_to? :delete
        # THINK about this. Perhaps the strategies should implement the backend methods?
        #
        @backend_weights.delete       if @backend_weights.respond_to?(:delete) && @weight_strategy.respond_to?(:saved?) && @weight_strategy.saved?
        @backend_similarity.delete    if @backend_similarity.respond_to? :delete
        @backend_configuration.delete if @backend_configuration.respond_to? :delete
        @backend_realtime.delete      if @backend_realtime.respond_to? :delete
      end
      
      # Saves the indexes in a dump file.
      #
      def dump
        @backend_inverted.dump @inverted
        # THINK about this. Perhaps the strategies should implement the backend methods? Or only the internal index ones?
        #
        @backend_weights.dump @weights       if @weight_strategy.respond_to?(:saved?) && @weight_strategy.saved?
        @backend_similarity.dump @similarity if @similarity_strategy.respond_to?(:saved?) && @similarity_strategy.saved?
        @backend_configuration.dump @configuration
        @backend_realtime.dump @realtime
      end
      
      # Loads all indexes.
      #
      # Loading loads index objects from the backend.
      # They should each respond to [] and return something appropriate.
      #
      def load
        @inverted      = @backend_inverted.load
        @weights       = @backend_weights.load unless @weight_strategy.respond_to?(:saved?) && !@weight_strategy.saved?
        @similarity    = @backend_similarity.load unless @similarity_strategy.respond_to?(:saved?) && !@similarity_strategy.saved?
        @configuration = @backend_configuration.load
        @realtime      = @backend_realtime.load
      end
      
      # Clears all indexes.
      #
      def clear
        @inverted.clear
        @weights.clear
        @similarity.clear
        @configuration.clear
        @realtime.clear
      end
      
      # This is the default behaviour and should be overridden
      # for different backends.
      #
      # TODO Push down.
      #
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        json bundle.index_path(:inverted)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      # def create_weights bundle
      #   json bundle.index_path(:weights)
      # end
      # # Returns an object that on #initial, #load returns
      # # an object that responds to:
      # #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      # #
      # def create_similarity bundle
      #   Marshal.new bundle.index_path(:similarity)
      # end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        json bundle.index_path(:configuration)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle
        json bundle.index_path(:realtime)
      end

      # Returns the total score of the combinations.
      #
      # Default implementation. Override to speed up.
      #
      def weight_for combinations
        combinations.score
      end

      # Returns the result ids for the allocation.
      #
      # Sorts the ids by size and & through them in the following order (sizes):
      # 0. [100_000, 400, 30, 2]
      # 1. [2, 30, 400, 100_000]
      # 2. (100_000 & (400 & (30 & 2))) # => result
      #
      # Note: Uses a C-optimized intersection routine (in performant.c)
      #       for speed and memory efficiency.
      #
      # Note: In the memory based version we ignore the amount and
      # offset hints.
      # We cannot use the information to speed up the algorithm,
      # unfortunately.
      #
      def ids_for combinations, _, _
        # Get the ids for each combination.
        #
        id_arrays = combinations.inject([]) do |total, combination|
          total << combination.ids
        end

        # Call the optimized C algorithm.
        #
        # Note: It orders the passed arrays by size.
        #
        Performant::Array.memory_efficient_intersect id_arrays
      end

      #
      #
      def to_s
        self.class.name
      end
      
      # Realtime
      #
      
      # TODO Make this a module to include in Memory and SQLite.
      #
      # Redis will define its own methods. Or should we build what Redis
      # is using, using a proxy which swallows up the commands from here
      # and then send it as a single command? Probably not possible.
      #
    
      # TODO Push methods back into the backend, so that we
      #      can apply more efficient methods tailored for
      #      each specific backends.
      #
    
      # Removes the given id from the indexes.
      #
      def remove id, weight_strategy, similarity_strategy
        # Is it anywhere?
        #
        str_or_syms = @realtime[id]

        return if str_or_syms.blank?

        str_or_syms.each do |str_or_sym|
          ids = @inverted[str_or_sym]
          ids.delete id

          if ids.empty?
            @inverted.delete str_or_sym
            @weights.delete  str_or_sym

            # Since no element uses this sym anymore, we can delete the similarity for it.
            #
            # TODO Not really. Since multiple syms can point to the same encoded.
            # In essence, we don't know if and when we can remove it.
            # (One idea is to add an array of ids and remove from that)
            #
            @similarity.delete similarity_strategy.encode(str_or_sym)
          else
            @weights[str_or_sym] = weight_strategy.weight_for ids.size
          end
        end

        @realtime.delete id
      end

      # Returns a reference to the array where the id has been added.
      #
      def add id, str_or_sym, weight_strategy, similarity_strategy, where
        str_or_syms = @realtime[id] ||= []

        # Inverted.
        #
        ids = if str_or_syms.include? str_or_sym
          ids = @inverted[str_or_sym] ||= []
          ids.delete id
          ids.send where, id
        else
          # Update the realtime index.
          #
          str_or_syms << str_or_sym
          ids = @inverted[str_or_sym] ||= []
          ids.send where, id
        end

        # Weights.
        #
        @weights[str_or_sym] = weight_strategy.weight_for ids.size

        # Similarity.
        #
        add_similarity str_or_sym, similarity_strategy, where

        # Return reference.
        #
        ids
      end

      # Add string/symbol to similarity index.
      #
      def add_similarity str_or_sym, similarity_strategy, where
        if encoded = similarity_strategy.encode(str_or_sym)
          similars = @similarity[encoded] ||= []

          # Not completely correct, as others will also be affected, but meh.
          #
          similars.delete str_or_sym if similars.include? str_or_sym
          similars << str_or_sym

          similarity_strategy.prioritize similars, str_or_sym
        end
      end

      # Partializes the text and then adds each.
      #
      def add_partialized id, text, partial_strategy, weight_strategy, similarity_strategy, where
        partialized text, partial_strategy do |partial_text|
          add id, partial_text, weight_strategy, similarity_strategy, where
        end
      end
      def partialized text, partial_strategy, &block
        partial_strategy.each_partial text, &block
      end

      # Builds the realtime mapping.
      #
      # Note: Experimental feature. Might be removed in 5.0.
      #
      # THINK Maybe load it and just replace the arrays with the corresponding ones.
      #
      # TODO Rename – prepare_for_realtime?
      #
      def build_realtime
        clear_realtime
        @inverted.each_pair do |str_or_sym, ids|
          ids.each do |id|
            str_or_syms = @realtime[id] ||= []
            @realtime[id] << str_or_sym unless str_or_syms.include? str_or_sym
          end
        end
      end

    end

  end

end