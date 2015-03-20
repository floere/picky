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
    def dump io_hash = {}
      @backend_inverted.dump @inverted, io_hash[:inverted]
      # THINK about this. Perhaps the strategies should implement the backend methods? Or only the internal index ones?
      #
      @backend_weights.dump @weights, io_hash[:weights] if @weight_strategy.respond_to?(:saved?) && @weight_strategy.saved?
      @backend_similarity.dump @similarity, io_hash[:similarity] if @similarity_strategy.respond_to?(:saved?) && @similarity_strategy.saved?
      @backend_configuration.dump @configuration, io_hash[:configuration]
      @backend_realtime.dump @realtime, io_hash[:realtime]
    end

  end

end