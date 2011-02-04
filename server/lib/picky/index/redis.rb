module Index
  
  class Redis < Backend
    
    def initialize bundle_name, configuration
      super bundle_name, configuration
      
      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @index         = Redis::ListHash.new bundle_name, :index
      @weights       = Redis::StringHash.new bundle_name, :weights
      @similarity    = Redis::ListHash.new bundle_name, :similarity
      @configuration = Redis::StringHash.new bundle_name, :configuration
    end
    
    # Delegate to the right collection.
    #
    def ids sym
      @index.collection sym
    end
    
    # Delegate to the right single value.
    #
    # Note: Converts to float.
    #
    def weight sym
      @weights.single(sym).to_f
    end
    
  end
  
end