# Fake ISBN class to demonstrate that #each indexing is working.
#
class ISBN
  mattr_reader :id
  attr_reader :id, :isbn

  self.id = 1

  def initialize(isbn)
    @id   = self.class.id += 1
    @isbn = isbn
  end
end
ISBNEachIndex = Picky::Index.new :isbn_each do
  key_format :to_i
  source   [ISBN.new('ABC'), ISBN.new('DEF')]
  category :isbn, qualifiers: %i[i isbn], key_format: :to_s
end
