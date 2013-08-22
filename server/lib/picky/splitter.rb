module Picky
  
  class Splitter
    
    def initialize
      @scanner = StringScanner.new ''
    end
    
    def single text, delimiter
      @scanner.string = text
      @scanner.scan_until delimiter
      [@scanner.pre_match, @scanner.post_match || @scanner.string]
    end
    
    def multi text, delimiter
      @scanner.string = text
      result = []
      loop do
        scanned = @scanner.scan_until delimiter
        result << (scanned && scanned[0..-2] || break)
      end
      if @scanner.pos.zero?
        result << text
      else
        result << @scanner.rest
      end
    end
    
  end
  
end