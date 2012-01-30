module Picky
  module Loggers
    
    # Default is the concise logger.
    #
    remove_const :Default if defined? Default
    Default = Concise.new
    
  end
end