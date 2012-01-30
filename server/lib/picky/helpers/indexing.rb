module Picky

  # Helper methods for measuring, benchmarking, logging.
  #
  module Helpers
    module Indexing

      include Measuring
      
      def timed_indexing scheduler, &block
        Picky.logger.info "Picky is indexing using #{scheduler.fork? ? 'multiple processes' : 'a single process'}: "
        Picky.logger.info " Done in #{timed(&block).round}s.\n"
      end

    end
  end

end