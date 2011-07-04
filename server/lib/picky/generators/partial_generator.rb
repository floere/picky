module Generators

  # The partial generator uses a subtoken(downto:1) generator as default.
  #
  class PartialGenerator < Base
  
    # Generate a partial index based on the given index.
    #
    def generate strategy = Partial::Substring.new(from: 1)
      strategy.generate_from self.index
    end

  end

end