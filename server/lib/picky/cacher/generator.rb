module Cacher

  # A cache generator holds an index type.
  #
  # TODO Rename to index_type.
  #
  class Generator

    attr_reader :index

    def initialize index
      @index = index
    end

  end

end