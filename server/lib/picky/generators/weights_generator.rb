module Generators

  # Uses a logarithmic algorithm as default.
  #
  class WeightsGenerator < Base

    # Generate a weights index based on the given inverted index.
    #
    def generate strategy = Weights::Logarithmic.new
      strategy.generate_from self.inverted
    end

  end

end