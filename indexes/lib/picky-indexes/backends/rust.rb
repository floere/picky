module Picky

  module Backends

    class Rust < Memory
      
      # Overrides the base implementation.
      #
      # A naïve implementation of an multi-Rust::Array#intersect.
      #
      def ids combinations, _, _
        id_arrays = combinations.map { |combination| combination.ids }.sort_by(&:size)
        id_arrays.inject(id_arrays.shift) do |result, id_array|
          result.intersect(id_array)
        end
      end
      
    end
    
  end
  
end