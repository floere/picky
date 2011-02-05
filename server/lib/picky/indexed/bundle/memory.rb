# encoding: utf-8
#
module Indexed # :nodoc:all
  
  #
  #
  module Bundle
    
    # This is the _actual_ index (based on memory).
    #
    # Handles exact/partial index, weights index, and similarity index.
    #
    # Delegates file handling and checking to an *Indexed*::*Files* object.
    #
    class Memory < Base
      
      attr_reader :index, :weights, :similarity, :configuration
      
      delegate :[], :to => :configuration
      
      def initialize name, configuration, *args
        super name, configuration, *args
        
        @configuration = {} # A hash with config options.
        
        @backend = ::Index::Files.new name, configuration
      end
      
      # Get the ids for the given symbol.
      #
      def ids sym
        @index[sym] || []
      end
      # Get a weight for the given symbol.
      #
      def weight sym
        @weights[sym]
      end
      
      # Loads the core index.
      #
      def load_index
        self.index = @backend.load_index
      end
      # Loads the weights index.
      #
      def load_weights
        self.weights = @backend.load_weights
      end
      # Loads the similarity index.
      #
      def load_similarity
        self.similarity = @backend.load_similarity
      end
      # Loads the configuration.
      #
      def load_configuration
        self.configuration = @backend.load_configuration
      end
      
    end
    
  end
  
end