module Internals

  module Tokenizers


    class Location < Base

      attr_reader :calculation

      def initialize options = {}
        super options

        grid      = options[:grid]
        precision = options[:precision] || 1

        @calculation = Internals::Calculations::Location.new grid, precision

        @minimum = 1.0 / 0

        @locations = []
      end

      # TODO Work on this!
      #
      def tokenize text

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