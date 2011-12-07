module Picky

  module Generators
    module Similarity
      # Default is no similarity.
      #
      remove_const :Default if defined? Default
      Default = None.new
    end
  end

end