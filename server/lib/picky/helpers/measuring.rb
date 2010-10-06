# Helper methods for measuring, benchmarking, logging.
#
module Helpers
  module Measuring
    
    # Returns a duration in seconds.
    #
    def timed(*args, &block)
      block_to_be_measured = lambda(&block)
      
      time_begin = Time.now.to_f
      
      block_to_be_measured.call(*args)
      
      Time.now.to_f - time_begin
    end
    
  end
end