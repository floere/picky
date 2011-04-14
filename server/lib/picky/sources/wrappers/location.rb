module Sources

  module Wrappers

    # Should this actually just be a tokenizer?
    #
    class Location < Base

      attr_reader :calculation

      def initialize source, grid, precision = 1
        super source
        @calculation = Internals::Calculations::Location.new grid, precision
      end

      # Yield the data (id, text for id) for the given category.
      #
      def harvest category
        minimum = 1.0/0

        # Cache. TODO Make option?
        #
        locations = []

        # Gather min/max.
        #
        source.harvest category do |indexed_id, location|
          location = location.to_f
          minimum = location if location < minimum
          locations << [indexed_id, location]
        end

        calculation.minimum = minimum

        # Recalculate locations.
        #
        locations.each do |indexed_id, location|
          calculation.recalculated_range(location).each do |new_location|
            yield indexed_id, new_location.to_s
          end
        end

        # TODO Move to the right place.
        #
        category.exact[:location_minimum] = minimum
      end

    end

  end

end