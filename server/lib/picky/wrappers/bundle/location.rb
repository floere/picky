module Picky

    module Wrappers

      module Bundle

        # A location calculation recalculates a location to the Picky internal location.
        #
        class Location < Calculation

          def initialize bundle, options = {}
            super bundle

            user_grid  = options[:grid]      || raise("Gridsize needs to be given for location #{bundle.identifier}.")
            anchor     = options[:anchor]    || 0.0
            precision  = options[:precision] || 1

            @calculation = Calculations::Location.new user_grid, anchor, precision
          end

          #
          #
          def add id, sym_or_string, where = :unshift
            bundle.add id, calculate(sym_or_string.to_s.to_f), where
          end

          # Do not generate a partial.
          #
          def add_partialized does_not, matter, at_all
            # Nothing
          end

          #
          #
          def calculate float
            @calculation.calculate float
          end

          # Save the config, then dump normally.
          #
          def dump
            bundle[:location_anchor] = @calculation.anchor
            bundle.dump
          end

          # Load first the bundle, then extract the config.
          #
          def load
            bundle.load
            anchor = bundle[:location_anchor] && bundle[:location_anchor].to_f || raise("Configuration :location_anchor for #{bundle.identifier} missing. Did you run rake index already?")
            @calculation.anchor = anchor
          end

        end

      end

  end

end