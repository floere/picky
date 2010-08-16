# encoding: utf-8
#
module Loggers
  # Log Proxy
  #
  class Search
    
    attr_reader :logger
    
    def initialize logger
      @logger = logger
    end
    
    def log message
      logger.info message
    end
    
  end
end