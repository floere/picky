class SwissLocations < Each
  module Accessibility
    def id
      self[0]
    end

    def location
      self[1]
    end

    def north
      self[2]
    end

    def east
      self[3]
    end
  end
end