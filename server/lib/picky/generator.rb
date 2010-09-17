module Picky
  
  # This is a very simple project generator.
  # Not at all like Padrino's or Rails'.
  # (No diss, just by way of a faster explanation)
  #
  # Basically copies a prototype project into a newly generated directory.
  #
  class Generator
    
    def run args
      p args
      Project
    end
    
    class Project
      
    end
    
  end
  
end