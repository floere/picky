module Internals

  module Index
  
    class Files < Backend
    
      def initialize bundle_name, config
        super bundle_name, config
      
        # Note: We marshal the similarity, as the
        #       Yajl json lib cannot load symbolized
        #       values, just keys.
        #
        @index         = File::JSON.new    config.index_path(bundle_name, :index)
        @weights       = File::JSON.new    config.index_path(bundle_name, :weights)
        @similarity    = File::Marshal.new config.index_path(bundle_name, :similarity)
        @configuration = File::JSON.new    config.index_path(bundle_name, :configuration)
      end
    
    end
  
  end
  
end