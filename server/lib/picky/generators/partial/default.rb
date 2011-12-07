module Picky

  module Generators
    module Partial
      remove_const :Default if defined? Default
      Default = Postfix.new from: -3
    end
  end

end