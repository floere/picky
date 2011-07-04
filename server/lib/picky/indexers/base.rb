# encoding: utf-8
#
module Indexers

  #
  #
  class Base

    # Starts the indexing process.
    #
    def index
      indexing_message
      process
    end

  end

end