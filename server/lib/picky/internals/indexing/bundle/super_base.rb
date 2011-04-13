module Internals

  # TODO Merge into Base, extract common with Indexed::Base.
  #
  module Indexing # :nodoc:all
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

      class SuperBase

        attr_reader   :identifier, :files
        attr_accessor :index, :weights, :similarity, :configuration, :similarity_strategy

        delegate :clear,    :to => :index
        delegate :[], :[]=, :to => :configuration

        def initialize name, category, similarity_strategy
          @identifier    = "#{category.identifier}:#{name}"
          @files         = Internals::Index::Files.new name, category

          @index         = {}
          @weights       = {}
          @similarity    = {}
          @configuration = {} # A hash with config options.

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

      end

    end

  end

end