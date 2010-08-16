module Cacher

  # Uses a logarithmic algorithm as default.
  #
  class WeightsGenerator < Generator

    # Generate a weights index based on the given index.
    #
    def generate strategy = Weights::Logarithmic.new
      strategy.generate_from self.index
    end

  end

end