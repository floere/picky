#
#
module Statistics
  
  #
  #
  class Count
    
    attr_reader :count
    
    #
    #
    def initialize pattern
      @pattern = pattern
      
      @count = 0
    end
    
    # Calculate the value starting from the given byte offset. 
    #
    def from offset
      
    end
    
    def reset_from
      @count = from offset
    end
    
    # Calculate and add the value starting from the given byte offset.
    #
    def add_from offset
      @count += from offset
    end
    
    # Count the pattern.
    #
    def count pattern, options = {}
      extended       = options[:extended] ? '-E' : '-G'
      nonmatching    = options[:nonmatching] ? '-v' : ''
      count_lines "#{extended} #{nonmatching} -i -s -e \"#{pattern}\" ", "#{@path}/tmp.log"
    end
    
    # Count the amount of lines the pattern matches.
    #
    def count_lines pattern, filename
      sys_i "grep -c #{pattern} #{filename}"
    end
    
    # Convert the system's response into an integer.
    #
    def sys_i text
      sys(text).to_i
    end
    
    # Run the text on the system.
    #
    def sys text
      `#{text}`.chomp
    end
    
    def to_s
      @count
    end
    
  end
  
end