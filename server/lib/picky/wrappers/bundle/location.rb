module Picky

    module Wrappers

      module Bundle

        # A location calculation recalculates a location to the Picky internal location.
        #
        class Location < Calculation

          def initialize bundle, user_grid, options = {}
            super bundle

            anchor     = options[:anchor]    || 0.0
            precision  = options[:precision] || 1

            @calculation = Calculations::Location.new user_grid, anchor, precision
          end

          #
          #
          def calculate float
            @calculation.calculate float
          end

          # Recalculates the added location.
          #
          def add id, location, where = :unshift
            @calculation.calculated_range(location.to_s.to_f).each do |new_location|
              bundle.add id, new_location.to_s, where
            end
          end

          # Do not generate a partial.
          #
          def add_partialized does_not, matter, at_all
            # Nothing
          end

          # Save the config, then dump normally.
          #
          def dump
            bundle['location_anchor'] = @calculation.anchor

            bundle.dump
          end

          # Load first the bundle, then extract the config.
          #
          def load
            bundle.load

            location_anchor     = bundle['location_anchor']
            @calculation.anchor = location_anchor && location_anchor.to_f || raise("Configuration 'location_anchor' for #{bundle.identifier} missing. Did you run rake index already?")
          end

        end

      end

  end

end