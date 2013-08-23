module Picky

  # Helper methods for measuring, benchmarking, logging.
  #
  module Helpers
    module Measuring

      # Returns a duration in seconds.
      #
      def timed
        time_begin = Time.new

        yield

        (Time.new - time_begin).to_f
      end

    end
  end

end