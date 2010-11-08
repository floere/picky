module Sources
  
  module Wrappers
    
    class Location < Base
      
      attr_reader :precision, :grid
      
      # TODO Save min and grid!
      #
      def initialize backend, options = {}
        super backend
        
        @user_grid = extract_user_grid options
        @precision = extract_precision options
        
        @grid      = @user_grid / (@precision + 0.5)
      end
      
      #
      #
      def extract_user_grid options
        options[:grid] || raise # TODO
      end
      # Extracts an amount of grids that this 
      # Precision is given in a value.
      # 1 is low (up to 16.6% error), 5 is very high (up to 5% error).
      #
      # We don't recommend using values higher than 5.
      #
      # Default is 1.
      #
      def extract_precision options
        options[:precision] || 1
      end
      
      def reset
        @min = 1.0/0
      end
      
      # Yield the data (id, text for id) for the given type and field.
      #
      def harvest type, field
        reset
        
        # Cache. TODO Make option?
        #
        locations = []
        
        # Gather min/max.
        #
        backend.harvest type, field do |indexed_id, location|
          location = location.to_f
          @min = location if location < @min
          locations << [indexed_id, location]
        end
        
        # Add a margin.
        #
        marginize
        
        # Recalculate locations.
        #
        locations.each do |indexed_id, location|
          locations_for(location).each do |new_location|
            yield indexed_id, new_location.to_s
          end
        end
      end
      
      def marginize
        @min -= @user_grid
      end
      
      # Put location onto multiple places on a grid.
      #
      # Note: Always returns an integer.
      #
      def locations_for location
        new_location = ((location - @min) / grid).floor
        
        min_location = new_location - precision
        max_location = new_location + precision
        
        (min_location..max_location).to_a
      end
    
    end
    
  end
  
end