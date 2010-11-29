module Calculations
  
  # A location calculation recalculates a 1-d location
  # to the Picky internal 1-d "grid".
  #
  # For example, if you have a location x == 12.3456,
  # it will be recalculated into 3, if the minimum is 9
  # and the gridlength is 1.
  #
  class Location
    
    attr_reader :minimum
    
    def initialize user_grid, precision = nil
      @user_grid = user_grid
      @precision = precision || 1
      @grid      = @user_grid / (@precision + 0.5)
    end
    
    def minimum= minimum
      # Add a margin of 1 user grid.
      #
      minimum -= @user_grid
      
      # Add plus 1 grid so that the index key never falls on 0.
      # Why? to_i maps by default to 0.
      #
      minimum -= @grid
      
      @minimum = minimum
    end
    
    #
    #
    def add_margin length
      @minimum -= length
    end
    
    #
    #
    def recalculate location
      ((location - @minimum) / @grid).floor
    end
    
  end
  
end