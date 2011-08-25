module Picky

  module Backends

    class Memory < Backend

      def configure_with bundle
        super bundle
        @inverted      = File::JSON.new    bundle.index_path(:inverted)
        @weights       = File::JSON.new    bundle.index_path(:weights)
        @similarity    = File::Marshal.new bundle.index_path(:similarity)
        @configuration = File::JSON.new    bundle.index_path(:configuration)
      end

    end

  end

end