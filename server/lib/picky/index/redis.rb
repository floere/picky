module Index
  
  class Redis < Backend
    
    def initialize bundle_name, config
      super bundle_name, config
      
      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @index         = Redis::Basic.new :index
      @weights       = Redis::Basic.new :weights
      @similarity    = Redis::Basic.new :similarity
      @configuration = Redis::Basic.new :configuration
    end
    
  end
  
end