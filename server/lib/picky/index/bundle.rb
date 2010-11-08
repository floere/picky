# encoding: utf-8
#
module Index

  # This is the ACTUAL index.
  #
  # Handles exact index, partial index, weights index, and similarity index.
  #
  # Delegates file handling and checking to a Index::Files object.
  #
  class Bundle < ::Bundle
    
    # Get the ids for the text.
    #
    def ids text
      @index[text] || []
    end
    # Get a weight for the text.
    #
    def weight text
      @weights[text]
    end
    # Get a list of similar texts.
    #
    def similar text
      code = similarity_strategy.encoded text
      code && @similarity[code] || []
    end
    
    # Load the data from the db.
    #
    def load_from_index_file
      load_from_index_generation_message
      clear
      retrieve
    end
    def load_from_index_generation_message
      timed_exclaim "LOAD INDEX #{identifier}."
    end
    # Retrieves the data into the index.
    #
    def retrieve
      files.retrieve do |id, token|
        initialize_index_for token
        index[token] << id
      end
    end
    def initialize_index_for token
      index[token] ||= []
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