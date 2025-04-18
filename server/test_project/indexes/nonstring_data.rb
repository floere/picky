# This checks that we can use a funky customized tokenizer.
#
NonStringDataSource = Struct.new :id, :nonstring
class NonStringTokenizer < Picky::Tokenizer
  def tokenize(nonstring)
    [nonstring.map(&:to_sym)]
  end
end
NonstringDataIndex = Picky::Index.new(:nonstring) do
  key_format :to_i
  source {
    [
      NonStringDataSource.new(1, ['gaga', :blabla, 'haha']),
      NonStringDataSource.new(2, [:meow, 'moo', :bang, 'zap'])
    ]
  }
  indexing NonStringTokenizer.new
  category :nonstring
end