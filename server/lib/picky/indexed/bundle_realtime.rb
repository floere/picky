module Picky

  module Indexed # :nodoc:all

    class Bundle < Picky::Bundle

      # TODO Dangerous to define it here.
      #
      def initialize *args
        super
        @inverted_id_array_lookup = {} # id -> ary.  TODO Always instantiate?
        @weights_lookup           = {} # id -> keys. TODO Always instantiate?
      end

      # TODO
      #
      def remove id
        array_of_id_arrays = @inverted_id_array_lookup[id]
        array_of_old_keys  = @weights_lookup[id]
        return unless array_of_id_arrays && array_of_old_keys

        array_of_id_arrays.each do |ary|
          ary.delete id # TODO Potentially very slow.
        end

        array_of_old_keys = @weights_lookup[id]
        return unless array_of_old_keys
        array_of_old_keys.each do |key|

        end
      end

      # Returns a reference to the array where the id has been added.
      #
      def add id, sym
        ary = @inverted[sym]
        p [:w, @weights]

        ary = if ary
          if ary.include? id # Note: Potentially very slow. Note *could* be done faster by weight. But…
            ary.unshift ary.delete id
          else
            @inverted_id_array_lookup[id] ||= []
            @inverted_id_array_lookup[id] << ary.unshift(id)
          end
        else
          @inverted_id_array_lookup[id] ||= []
          @inverted_id_array_lookup[id] << (@inverted[sym] = [id])
        end

        new_weight = self.weights_strategy.amount_for ary.size

        @weights_lookup[id] ||= [] # TODO Move to top and do nothing if it's already in the weights?
        @weights_lookup[id] << sym

        p [:w, @weights]
      end

    end

  end

end