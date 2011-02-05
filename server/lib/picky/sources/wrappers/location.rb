module Sources
  
  module Wrappers
    
    class Location < Base
      
      attr_reader :precision, :grid
      
      # TODO Save min and grid!
      #
      def initialize category, options = {}
        super category
        
        @precision   = extract_precision options
        @calculation = Calculations::Location.new extract_user_grid(options), @precision
      end
      
      #
      #
      def extract_user_grid options
        options[:grid] || raise("Option :grid needs to be passed to a location.")
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
      
      # Yield the data (id, text for id) for the given type and category.
      #
      def harvest type, category
        minimum = 1.0/0
        
        # Cache. TODO Make option?
        #
        locations = []
        
        # Gather min/max.
        #
        backend.harvest type, category do |indexed_id, location|
          location = location.to_f
          minimum = location if location < minimum
          locations << [indexed_id, location]
        end
        
        @calculation.minimum = minimum
        
        # Recalculate locations.
        #
        locations.each do |indexed_id, location|
          locations_for(@calculation.recalculate(location)).each do |new_location|
            yield indexed_id, new_location.to_s
          end
        end
        
        # TODO Move to the right place.
        #
        category.exact[:location_minimum].to_f = minimum
      end
      
      # Put location onto multiple places on a grid.
      #
      # Note: Always returns an integer.
      #
      def locations_for repositioned_location
        min_location = repositioned_location - precision
        max_location = repositioned_location + precision
        
        (min_location..max_location).to_a
      end
    
    end
    
  end
  
end