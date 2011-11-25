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
  # * *Indexing*::*Bundle* is just concerned with creating index files
  #   and providing helper functions to e.g. check the indexes.
  #
  # * *Index*::*Bundle* is concerned with loading these index files into
  #   memory and looking up search data as fast as possible.
  #
  # This is the indexing bundle.
  #
  # It does all menial tasks that have nothing to do
  # with the actual index running etc.
  # (Find these in Indexed::Bundle)
  #
  class Bundle

    # Saves the indexes in a dump file.
    #
    def dump
      dump_inverted
      dump_similarity
      dump_weights
      dump_configuration
      dump_realtime
    end
    # Dumps the core index.
    #
    def dump_inverted
      @backend_inverted.dump @inverted
    end
    # Dumps the weights index.
    #
    def dump_weights
      # TODO THINK about this. Perhaps the strategies should implement the backend methods? Or only the internal index ones?
      #
      @backend_weights.dump @weights if @weights_strategy.saved?
    end
    # Dumps the similarity index.
    #
    def dump_similarity
      @backend_similarity.dump @similarity if @similarity_strategy.saved?
    end
    # Dumps the configuration.
    #
    def dump_configuration
      @backend_configuration.dump @configuration
    end
    # Dumps the realtime.
    #
    def dump_realtime
      @backend_realtime.dump @realtime
    end

  end

end