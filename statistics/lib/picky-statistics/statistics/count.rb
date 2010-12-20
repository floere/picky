#
#
module Statistics
  
  #
  #
  class Count
    
    attr_reader :count
    
    #
    #
    def initialize *patterns
      @patterns = patterns
      
      @count = 0
    end
    
    # Calculate the value starting from the given byte offset. 
    #
    def from filename, options = {}
      @patterns.inject(0) do |total, pattern|
        total + count(pattern, filename, options)
      end
    end
    
    # Calculate and reset the value starting from the given byte offset.
    #
    def reset_from filename, options = {}
      @count = from filename, options
    end
    
    # Calculate and add the value starting from the given byte offset.
    #
    def add_from filename, options = {}
      @count += from filename, options
    end
    
    # Count the pattern.
    #
    def count pattern, filename, options = {}
      extended       = options[:extended] ? '-E' : '-G'
      nonmatching    = options[:nonmatching] ? '-v' : ''
      count_lines "#{extended} #{nonmatching} -i -s -e \"#{pattern}\"", filename
    end
    
    # Count the amount of lines the pattern matches.
    #
    def count_lines extended_pattern, filename
      puts "grep -c #{extended_pattern} #{filename}"
      sys_i "grep -c #{extended_pattern} #{filename}"
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
      @count.to_s
    end
    
  end
  
end