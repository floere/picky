# Fake ISBN class to demonstrate that #each indexing is working.
#
class ISBN
  @@id = 1
  attr_reader :id, :isbn
  def initialize isbn
    @id   = @@id += 1
    @isbn = isbn
  end
end
ISBNEachIndex = Picky::Index.new :isbn_each do
  key_format :to_i
  source   [ISBN.new('ABC'), ISBN.new('DEF')]
  category :isbn, :qualifiers => [:i, :isbn], :key_format => :to_s
end