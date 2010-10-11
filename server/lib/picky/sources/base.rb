module Sources
  
  # Sources are where your data comes from.
  # Harvest is the most important method as it is used always to get data.
  #
  class Base
    
    # Note: Methods listed for illustrative purposes.
    #
    
    # Yield the data (id, text for id) for the given type and field.
    #
    def harvest type, field
      # yields nothing
    end
    
    # Connects to the backend.
    #
    def connect_backend
      
    end
    
    # Take a snapshot of your data, if it is fast changing.
    #
    def take_snapshot type
      
    end
    
  end
  
end