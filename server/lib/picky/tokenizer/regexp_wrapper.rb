class RegexpWrapper
  
  def initialize regexp
    @regexp = regexp
  end
  
  def split text
    text.split @regexp
  end
  
  def source
    @regexp.source
  end
  
  def method_missing name, *args, &block
    @regexp.send name, *args, &block
  end

end