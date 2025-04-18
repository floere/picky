class SymbolKeys < Each

  module Accessibility
    def id
      self[0]
    end

    def text
      self[1]
    end
  end

end
