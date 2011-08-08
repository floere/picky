# Extending the Symbol class.
#
class Symbol # :nodoc:all

  # :keys.each_subtoken    # => yields each of [:keys, :key, :ke, :k]
  # :keys.each_subtoken(2) # => yields each of [:keys, :key, :ke]
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