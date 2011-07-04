module Generators # :nodoc:all

  # A cache generator holds an index.
  #
  class Base
  
    attr_reader :index
  
    def initialize index
      @index = index
    end
  
  end

end