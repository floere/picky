# encoding: utf-8
#
module Index

  # This is the _actual_ index.
  #
  # Handles exact/partial index, weights index, and similarity index.
  #
  # Delegates file handling and checking to a Index::Files object.
  #
  class Bundle < ::Bundle
    
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
    
    # Load the data from the db.
    #
    def load_from_index_file
      load_from_index_generation_message
      clear
      retrieve
    end
    # Notifies the user that the index is being loaded.
    #
    def load_from_index_generation_message
      timed_exclaim "LOAD INDEX #{identifier}."
    end
    
    # Loads all indexes into this category.
    #
    def load
      load_index
      load_similarity
      load_weights
    end
    def load_index
      self.index = files.load_index
    end
    def load_similarity
      self.similarity = files.load_similarity
    end
    def load_weights
      self.weights = files.load_weights
    end
    
  end
end