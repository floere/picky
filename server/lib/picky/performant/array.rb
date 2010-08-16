module Performant
  # This class will be enriched with c-methods
  #
  class Array

    # Chooses a good algorithm for intersecting arrays.
    #
    # Note: The sort order will be changed.
    #
    def self.intersect array_of_arrays
      array_of_arrays.sort! { |a, b| a.size <=> b.size }

      if (array_of_arrays.sum(&:size) < 20_000)
        Performant::Array.brute_force_intersect array_of_arrays
      else
        array_of_arrays.inject([]) do |total, elements|
          total.empty? ? elements : elements & total
        end
      end
    end

  end
end