module Results
  # Live results are not returning any results.
  #
  class Live < Base
    
    self.max_results = 0
    
    def to_log *args
      ?. + super
    end
    
    # The default response style for live results is to_json.
    #
    def to_response
      to_json
    end
    
  end
end