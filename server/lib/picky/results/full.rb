module Results
  # Full results are limited to maximally 20 results (by default).
  #
  class Full < Base
    
    self.max_results = 20
    
    def to_log *args
      ?> + super
    end
    
  end
end