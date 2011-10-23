module Picky

  module Indexed # :nodoc:all

    class Bundle < Picky::Bundle

      # TODO
      #
      def remove id
        # Is it anywhere?
        #
        syms = @realtime_mapping[id]
        return unless syms

        syms.each do |sym|
          ids = @inverted[sym]
          ids.delete id

          if ids.empty?
            @inverted.delete sym
            @weights.delete  sym
          else
            @weights[sym] = self.weights_strategy.weight_for ids.size
          end
        end

        p [:@inverted_in_remove, @inverted]

        @realtime_mapping.delete id
      end

      # Returns a reference to the array where the id has been added.
      #
      def add id, sym
        ary = @inverted[sym]

        syms = @realtime_mapping[id]
        syms = @realtime_mapping[id] = [] unless syms # TODO Nicefy.

        ids = if syms.include? sym
          ids = @inverted[sym]
          ids.delete  id
          ids.unshift id
        else
          syms << sym
          @inverted[sym] = [id]
        end
        @weights[sym] = self.weights_strategy.weight_for ids.size
      end

    end

  end

end