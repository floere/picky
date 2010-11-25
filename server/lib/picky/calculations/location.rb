module Calculations
  
  # A location calculation recalculates a 1-d location
  # to the Picky internal 1-d "grid".
  #
  # For example, if you have a location x == 12.3456,
  # it will be recalculated into 3, if the minimum is 9
  # and the gridlength is 1.
  #
  class Location
    
    def initialize minimum, gridlength
      @minimum    = minimum
      @gridlength = gridlength
    end
    
    #
    #
    def add_margin length
      @minimum -= length
    end
    
    #
    #
    def reposition location
      ((location - @minimum) / @gridlength).floor
    end
    
  end
  
end