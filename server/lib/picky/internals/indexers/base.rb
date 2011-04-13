# encoding: utf-8
#
module Indexers

  #
  #
  class Base

    # Selects the original id (indexed id) and a column to process. The column data is called "token".
    #
    # Note: Puts together the parts first in an array, then releasing the array from time to time by joining.
    #
    def index
      indexing_message
      process
    end

    # Delegates the key format to the source.
    #
    # Default is to_i.
    #
    def key_format
      source.respond_to?(:key_format) && source.key_format || :to_i
    end

  end

end