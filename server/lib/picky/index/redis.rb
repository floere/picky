module Index
  
  class Redis < Backend
    
    def initialize bundle_name, config
      super bundle_name, config
      
      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      # TODO
      #
      @index         = Redis::ListHash.new "#{config.identifier}:#{bundle_name}:index"
      @weights       = Redis::StringHash.new "#{config.identifier}:#{bundle_name}:weights"
      @similarity    = Redis::ListHash.new "#{config.identifier}:#{bundle_name}:similarity"
      @configuration = Redis::StringHash.new "#{config.identifier}:#{bundle_name}:configuration"
    end
    
    # Delegate to the right collection.
    #
    def ids sym
      @index.collection sym
    end
    
    # Delegate to the right member value.
    #
    # Note: Converts to float.
    #
    def weight sym
      @weights.member(sym).to_f
    end
    
    # Delegate to a member value.
    #
    def configuration sym
      @configuration.member sym
    end
    
  end
  
end