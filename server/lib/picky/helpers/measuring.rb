module Picky

  # Helper methods for measuring, benchmarking, logging.
  #
  module Helpers
    module Measuring

      # Returns a duration in seconds.
      #
      def timed *args, &block_to_be_measured
        time_begin = Time.new

        block_to_be_measured.call *args

        (Time.new - time_begin).to_f
      end

    end
  end

end