module Query

  # This Query class performs full queries.
  #
  # It includes in its results:
  # * A count of results.
  # * All possible combinations with its weights.
  # * The top X result ids.
  #
  class Full < Base

    # Returns Results::Full as its result type.
    #
    def result_type
      Internals::Results::Full
    end

  end

end