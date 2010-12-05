# encoding: utf-8
#
module Indexed # :nodoc:all

  # This is the _actual_ index.
  #
  # Handles exact/partial index, weights index, and similarity index.
  #
  # Delegates file handling and checking to an *Indexed*::*Files* object.
  #
  class Bundle < Index::Bundle
    
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
      self.index = files.load_index
    end
    # Loads the weights index.
    #
    def load_weights
      self.weights = files.load_weights
    end
    # Loads the similarity index.
    #
    def load_similarity
      self.similarity = files.load_similarity
    end
    # Loads the configuration.
    #
    def load_configuration
      self.configuration = files.load_configuration
    end
    
  end
end