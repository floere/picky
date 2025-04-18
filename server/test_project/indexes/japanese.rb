require_relative '../models/japanese'
JapaneseIndex = Picky::Index.new(:japanese) do
  key_format :to_i
  source   { Japanese.all('data/japanese.tab', col_sep: "\t") }

  indexing removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\s;]/,
           stopwords: /\b(and|the|of|it|in|for)\b/i,
           splits_text_on: /[\s;]/

  category :japanese,
           partial: Picky::Partial::Substring.new(from: 1)
end
