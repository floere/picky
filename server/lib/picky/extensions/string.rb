# Extending the String class.
#
class String # :nodoc:all

  # 'keys'.each_subtoken    # => yields each of ['keys', 'key', 'ke', 'k']
  # 'keys'.each_subtoken(2) # => yields each of ['keys', 'key', 'ke']
  #
  def each_subtoken from_length = 1, range = nil
    sub = self

    sub = sub[range] if range

    yield sub

    size = sub.size
    from_length = size + from_length + 1 if from_length < 0
    from_length = size if size < from_length
    from_length = 1 if from_length < 1

    size.downto(from_length + 1) { yield sub = sub.chop }
  end

  # 'keys'.each_intoken         # => yields each of ['keys', 'key', 'eys', 'ke', 'ey', 'ys', 'k', 'e', 'y', 's']
  # 'keys'.each_intoken(2)      # => yields each of ['keys', 'key', 'eys', 'ke', 'ey', 'ys']
  # 'keys'.each_intoken(2, 3)   # => yields each of ['key', 'eys', 'ke', 'ey', 'ys']
  # 'keys'.each_intoken(10, 12) # => yields nothing (min larger than str)
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
        yield self[offset, length]
      end
      this_many += 1
    end
  end

end