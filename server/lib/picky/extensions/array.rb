# The Array class we all know and love.
#
class Array

  # Cluster-uniqs equal neighborly elements.
  #
  # Returns a copy.
  #
  def clustered_uniq
    self.inject([]) do |result, element|
      result << element if element != result.last
      result
    end
  end

  #
  #
  def map_with_index!
    each_with_index do |element, index| self[index] = yield(element, index); end
  end

  #
  #
  def map_with_index &block
    dup.map_with_index! &block
  end

  # Accesses a random element of this array.
  #
  def random
    self[Kernel.rand(self.length)]
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