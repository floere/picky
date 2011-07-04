module Generators

  # Uses a logarithmic algorithm as default.
  #
  class WeightsGenerator < Base

    # Generate a weights index based on the given index.
    #
    def generate strategy = Weights::Logarithmic.new
      strategy.generate_from self.index
    end

  end

end