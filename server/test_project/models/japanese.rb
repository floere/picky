class Japanese < Each
  module Accessibility
    def id
      self[0]
    end

    def japanese
      self[1]
    end

    def german
      self[2]
    end
  end
end
