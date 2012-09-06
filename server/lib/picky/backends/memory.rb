module Picky

  module Backends

    class Memory < Backend
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        Marshal.new bundle.index_path(:similarity)
      end

    end

  end

end