module Query

  # This is the query class for live queries.
  #
  # It does:
  #  * Return a count of results.
  #
  # It does NOT:
  #  * Sort results geographically.
  #  * Do any postprocessing.
  #
  class Live < Base

    # Generates results from allocations.
    #
    def result_type
      Results::Live
    end

  end

end