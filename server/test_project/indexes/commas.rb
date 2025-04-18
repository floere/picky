# This checks that we can use a funky customized tokenizer.
#
klass_with_commas_in_ids = Struct.new :id, :text
CommaIdsIndex = Picky::Index.new(:commas) do
  key_format :to_s
  source do
    [
      klass_with_commas_in_ids.new('a,b', 'text with a, b'),
      klass_with_commas_in_ids.new('c,d', 'text with c, d')
    ]
  end
  category :text
end
