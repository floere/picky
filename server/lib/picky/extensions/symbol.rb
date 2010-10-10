# Extending the Symbol class.
#
class Symbol
  
  # :keys.subtokens    # => [:key, :ke, :k]
  # :keys.subtokens(2) # => [:key, :ke]
  #
  def subtokens down_to_length = 1
    sub, result = self.to_s, [self]
    
    size = sub.size
    down_to_length = size + down_to_length if down_to_length < 0
    down_to_length = size if size < down_to_length
    
    size.downto(down_to_length + 1) { result << sub.chop!.to_sym }
    result
  end
  
end