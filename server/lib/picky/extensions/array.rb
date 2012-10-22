# The Array class we all know and love.
#
class Array

  # Around 10% faster than the above.
  #
  # Returns a copy.
  #
  def clustered_uniq
    result = []
    self.inject(nil) do |last, element|
      if last == element
        last
      else
        result << element && element
      end
    end
    result
  end

  # Sort the array using distance from levenshtein.
  #
  # Will raise if encounters not to_s-able element.
  #
  def sort_by_levenshtein! from
    from = from.to_s
    sort! do |this, that|
      Text::Levenshtein.distance(this.to_s, from) <=> Text::Levenshtein.distance(that.to_s, from)
    end
  end

end