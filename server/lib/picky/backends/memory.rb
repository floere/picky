module Picky

  module Backends

    class Memory < Backend
      
      def create_weights bundle
        JSON.new bundle.index_path(:weights)
      end
      
      def create_similarity bundle
        Marshal.new bundle.index_path(:similarity)
      end

    end

  end

end