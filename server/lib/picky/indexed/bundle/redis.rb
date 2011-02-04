# encoding: utf-8
#
module Indexed # :nodoc:all
  
  #
  #
  module Bundle
    
    # This is the _actual_ index (based on Redis).
    #
    # Handles exact/partial index, weights index, and similarity index.
    #
    class Redis < Index::Bundle
      
      def initialize name, configuration, *args
        super name, configuration, *args
        
        @backend = ::Index::Redis.new name, configuration
      end
      
      # Get the ids for the given symbol.
      #
      # Ids are an array of string values in Redis.
      #
      def ids sym
        @backend.ids sym
      end
      # Get a weight for the given symbol.
      #
      # A weight is a string value in Redis. TODO Convert?
      #
      def weight sym
        @backend.weight sym
      end
      
      # Loads all indexes.
      #
      def load
        load_index
        load_weights
        load_similarity
        load_configuration
      end
      # Loads the core index.
      #
      def load_index
        # TODO check if it is there.
      end
      # Loads the weights index.
      #
      def load_weights
        # TODO check if it is there.
      end
      # Loads the similarity index.
      #
      def load_similarity
        # TODO check if it is there.
      end
      # Loads the configuration.
      #
      def load_configuration
        # TODO check if it is there.
      end
      
    end
    
  end
  
end