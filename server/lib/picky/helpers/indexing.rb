module Picky

  # Helper methods for measuring, benchmarking, logging.
  #
  module Helpers
    module Indexing

      include Measuring

      # Returns a duration in seconds.
      #
      def timed_indexing scheduler, &block
        timed_exclaim "Indexing using #{scheduler.fork? ? 'multiple processes' : 'a single process'}."
        timed_exclaim "Indexing finished after #{timed(&block).round}s."
      end

    end
  end

end