module Cacher

  # The partial generator uses a subtoken(downto:1) generator as default.
  #
  class PartialGenerator < Generator
    
    # Generate a similarity index based on the given index.
    #
    def generate strategy = Partial::Subtoken.new(:down_to => 1)
      strategy.generate_from self.index
    end

  end
  
end