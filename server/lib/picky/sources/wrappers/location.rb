module Sources

  module Wrappers

    class Location < Base

      attr_reader :calculation

      # TODO Save min and grid!
      #
      def initialize source, grid, precision
        super source
        @calculation = Calculations::Location.new grid, precision
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
        backend.harvest category do |indexed_id, location|
          location = location.to_f
          minimum = location if location < minimum
          locations << [indexed_id, location]
        end

        calculation.minimum = minimum

        # Recalculate locations.
        #
        locations.each do |indexed_id, location|
          # TODO Rewrite.
          #
          locations_for(@calculation.recalculate(location)).each do |new_location|
            yield indexed_id, new_location.to_s
          end
        end

        # TODO Move to the right place.
        #
        category.exact[:location_minimum] = minimum
      end

      # Put location onto multiple places on a grid.
      #
      # Note: Always returns an integer.
      #
      def locations_for repositioned_location
        calculation.range(repositioned_location).to_a
      end

    end

  end

end