module Picky

  module Indexed # :nodoc:all

    class Bundle < Picky::Bundle

      # Removes the given id from the indexes.
      #
      def remove id
        # Is it anywhere?
        #
        syms = @realtime_mapping[id]
        return unless syms

        syms.each do |sym|
          ids = @inverted[sym]
          ids.delete id

          encoded = self.similarity_strategy.encoded sym

          if ids.empty?
            @inverted.delete   sym
            @weights.delete    sym
            # Since no element uses this sym anymore, we can delete the similarity for it.
            # TODO Not really. Since multiple syms can point to the same encoded.
            @similarity.delete encoded
          else
            @weights[sym] = self.weights_strategy.weight_for ids.size
          end
        end

        @realtime_mapping.delete id
      end

      # Returns a reference to the array where the id has been added.
      #
      def add id, sym
        ary = @inverted[sym]

        syms = @realtime_mapping[id]
        syms = (@realtime_mapping[id] = []) unless syms # TODO Nicefy.

        # Inverted.
        #
        ids = if syms.include? sym
          ids = @inverted[sym]
          ids.delete  id # Move id
          ids.unshift id # to front
        else
          syms << sym
          inverted = @inverted[sym] ||= []
          inverted.unshift id
        end

        # Weights.
        #
        @weights[sym] = self.weights_strategy.weight_for ids.size

        # Similarity.
        #
        if encoded = self.similarity_strategy.encoded(sym)
          similarity = @similarity[encoded] ||= []
          if similarity.include? sym
            similarity.delete sym  # Not completely correct, as others will also be affected, but meh.
            similarity.unshift sym #
          else
            similarity.unshift sym
          end
        end
      end

    end

  end

end