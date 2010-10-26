# Extending the Symbol class.
#
class Symbol
  
  # :keys.subtokens    # => [:keys, :key, :ke, :k]
  # :keys.subtokens(2) # => [:keys, :key, :ke]
  #
  def subtokens from_length = 1
    sub = self.id2name
    
    size = sub.size
    from_length = size + from_length if from_length < 0
    from_length = size if size < from_length
    
    result = [self]
    size.downto(from_length + 1) { result << sub.chop!.intern }
    result
  end
  
  # TODO Duplicate code.
  #
  def each_subtoken from_length = 1
    sub = self.id2name
    
    size = sub.size
    from_length = size + from_length + 1 if from_length < 0
    from_length = size if size < from_length
    from_length = 1 if from_length < 1
    
    yield self
    size.downto(from_length + 1) { yield sub.chop!.intern }
  end
  
end