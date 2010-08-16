module Query

  # This is the query class for performing full fledged queries.
  #
  class Full < Base

    # Generates full results.
    #
    def result_type
      Results::Full
    end

  end

end