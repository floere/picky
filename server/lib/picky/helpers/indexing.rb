module Picky

  # Helper methods for measuring, benchmarking, logging.
  #
  module Helpers
    module Indexing

      include Measuring

      # Runs the block and logs a few infos regarding the time it took.
      #
      def timed_indexing scheduler, &block
        Picky.logger.info "Picky is indexing using #{scheduler.fork? ? 'multiple processes' : 'a single process'}: "
        Picky.logger.info " Done in #{timed(&block).round}s.\n"
      end

      # Indexing works the same way, always:
      #  * Prepare the scheduler.
      #  * Cache the scheduler.
      #
      def index scheduler = Scheduler.new
        timed_indexing scheduler do
          prepare scheduler
          scheduler.finish

          cache scheduler
          scheduler.finish
        end
      end

    end
  end

end