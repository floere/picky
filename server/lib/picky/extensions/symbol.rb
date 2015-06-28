# Extending the Symbol class.
#
class Symbol

  # Returns a _single_ double metaphone code
  # for this symbol.
  #
  def double_metaphone
    codes = Text::Metaphone.double_metaphone self
    codes.first.intern unless codes.empty?
  end

  # Returns a metaphone code for this symbol.
  #
  def metaphone
    code = Text::Metaphone.metaphone self.to_s
    code.intern if code
  end

  # Returns a soundex code for this symbol.
  #
  def soundex
    code = Text::Soundex.soundex self.to_s
    code.intern if code
  end

  # :keys.each_subtoken    # => yields each of [:keys, :key, :ke, :k]
  # :keys.each_subtoken(2) # => yields each of [:keys, :key, :ke]
  #
  def each_subtoken from_length = 1, range = nil
    sub = self.id2name

    if range
      unless (range.first.zero? && range.last == -1)
        sub = sub[range]
      end
    end

    yield sub.intern

    size = sub.size
    from_length = size + from_length + 1 if from_length < 0
    from_length = size if size < from_length
    from_length = 1 if from_length < 1

    size.downto(from_length + 1) do
      yield sub.chop!.intern
    end
  end

  # :keys.each_intoken         # => yields each of [:keys, :key, :eys, :ke, :ey, :ys, :k, :e, :y, :s]
  # :keys.each_intoken(2)      # => yields each of [:keys, :key, :eys, :ke, :ey, :ys]
  # :keys.each_intoken(2, 3)   # => yields each of [:key, :eys, :ke, :ey, :ys]
  # :keys.each_intoken(10, 12) # => yields nothing (min larger than sym)
  #
  def each_intoken min_length = 1, max_length = -1
    max_length = size + max_length + 1 if max_length < 0
    max_length = size if size < max_length
    max_length = 1 if max_length < 1

    min_length = size + min_length + 1 if min_length < 0
    min_length = 1 if min_length < 1

    this_many = size - max_length + 1
    max_length.downto(min_length) do |length|
      this_many.times do |offset|
        yield self[offset, length].intern
      end
      this_many += 1
    end
  end

end