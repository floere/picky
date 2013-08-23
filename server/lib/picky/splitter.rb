module Picky
  
  class Splitter < StringScanner
    
    def initialize delimiter
      @delimiter = delimiter
      super ''
    end
    
    def single text
      self.string = text
      skip_until @delimiter
      [pre_match, post_match || string]
    end
    
    def multi text
      self.string = text
      if exist? @delimiter
        text.split @delimiter
      else
        [text]
      end
    end
    
  end
  
end