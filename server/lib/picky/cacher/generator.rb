module Cacher # :nodoc:all
  
  # A cache generator holds an index.
  #
  class Generator
    
    attr_reader :index
    
    def initialize index
      @index = index
    end
    
  end
  
end