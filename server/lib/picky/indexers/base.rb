# encoding: utf-8
#
module Indexers

  #
  #
  class Base

    attr_reader :index_or_category

    delegate :source, :to => :index_or_category

    def initialize index_or_category
      @index_or_category = index_or_category
    end

    # Starts the indexing process.
    #
    def index categories
      start_indexing_message
      prepare categories
      process categories
      finish_indexing_message
    end

    # By default, an indexer
    #  * prepares the index directories.
    #
    def prepare categories
      categories.each &:prepare_index_directory
    end

  end

end