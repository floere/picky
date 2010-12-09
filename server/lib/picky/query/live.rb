module Query

  # This Query class performs live queries.
  #
  # It is useful for updating counters, or any job where you don't need the result ids.
  #
  # It includes in its results:
  # * A count of results.
  # * All possible combinations with its weights.
  #
  # But not:
  # * The top X result ids.
  #
  class Live < Base

    # Returns Results::Live as its result type.
    #
    def result_type
      Results::Live
    end

  end

end