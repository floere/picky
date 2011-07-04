module Internals
  module Indexed
    module Wrappers

      module Bundle

        # A location calculation recalculates a location to the Picky internal location.
        #
        class Location < Calculation

          def initialize bundle, options = {}
            super bundle

            precision  = options[:precision] || 1
            user_grid  = options[:grid] || raise("Gridsize needs to be given for location #{bundle.identifier}.")

            @calculation = Internals::Calculations::Location.new user_grid, precision
          end

          #
          #
          def recalculate float
            @calculation.recalculate float
          end

          #
          #
          def load
            # Load first the bundle, then extract the config.
            #
            bundle.load
            # TODO Move the to_f to the backend.
            #
            minimum = bundle[:location_minimum] && bundle[:location_minimum].to_f || raise("Configuration :location_minimum for #{bundle.identifier} missing. Did you run rake index already?")
            @calculation.minimum = minimum
          end

        end

      end

    end
  end
end