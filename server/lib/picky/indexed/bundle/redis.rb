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
      
      def initialize *args
        super *args
        # TODO Does a keyspace exist?
        #
        @backend = Redis.new # TODO Pass this in.
      end
      
      # Get the ids for the given symbol.
      #
      # Ids are an array of string values in Redis.
      #
      def ids sym
        @backend.lrange "#{identifier} index #{sym}", 0, 100_000_000_000
      end
      # Get a weight for the given symbol.
      #
      # A weight is a string value in Redis. TODO Convert?
      #
      def weight sym
        @backend.get("#{identifier} weight #{sym}").to_f
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