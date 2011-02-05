module Indexed # :nodoc:all
  # TODO Rewrite.
  #
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
  # * *Indexing*::*Bundle* is just concerned with creating index files
  #   and providing helper functions to e.g. check the indexes.
  #
  # * *Index*::*Bundle* is concerned with loading these index files into
  #   memory and looking up search data as fast as possible.
  #
  module Bundle
    
    class Base
    
      attr_reader   :identifier, :configuration
      attr_accessor :similarity_strategy
      
      delegate :[], :to => :configuration
    
      def initialize name, configuration, similarity_strategy
        @identifier = "#{configuration.identifier} (#{name})"
      
        @index         = {}
        @weights       = {}
        @similarity    = {}
      
        @similarity_strategy = similarity_strategy
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
      
      # Loads all indexes.
      #
      def load
        load_index
        load_weights
        load_similarity
        load_configuration
      end
      
    end
    
  end
end