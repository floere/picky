module Picky
  module Backends

    class Rust < Memory
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle, hints = nil
        Basic.new bundle.index_path(:inverted), hash_for(hints)
      end
      
      # Overrides the base implementation.
      #
      # A naïve implementation of an multi-Rust::Array#intersect.
      #
      def ids combinations, _, _
        id_arrays = combinations.map { |combination| combination.ids }.sort_by(&:size)
        p id_arrays.map(&:class)
        id_arrays.inject(id_arrays.shift) do |result, id_array|
          result.intersect(id_array)
        end
      end
      
    end
    
  end
end