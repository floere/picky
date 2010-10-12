# Extending the Symbol class.
#
class Symbol
  
  # :keys.subtokens    # => [:keys, :key, :ke, :k]
  # :keys.subtokens(2) # => [:keys, :key, :ke]
  #
  def subtokens down_to_length = 1
    sub = self.id2name
    
    size = sub.size
    down_to_length = size + down_to_length if down_to_length < 0
    down_to_length = size if size < down_to_length
    
    result = [self]
    size.downto(down_to_length + 1) { result << sub.chop!.intern }
    result
  end
  
  # TODO Duplicate code.
  #
  def each_subtoken down_to_length = 1
    sub = self.id2name
    
    size = sub.size
    down_to_length = size + down_to_length + 1 if down_to_length < 0
    down_to_length = size if size < down_to_length
    down_to_length = 1 if down_to_length < 1
    
    yield self
    size.downto(down_to_length + 1) { yield sub.chop!.intern }
  end
  
end