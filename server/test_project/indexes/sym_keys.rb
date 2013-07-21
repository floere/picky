require_relative '../models/symbol_keys'
SymKeysIndex = Picky::Index.new :symbol_keys do
  key_format :to_i
  key_format :strip
  source   { SymbolKeys.all("data/#{PICKY_ENVIRONMENT}/symbol_keys.csv") }
  category :text, partial: Picky::Partial::Substring.new(from: 1)
end