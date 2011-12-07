module Picky

  module Generators
    module Weights
      # Default is Logarithmic.
      #
      remove_const :Default if defined? Default
      Default = Logarithmic.new
    end
  end

end