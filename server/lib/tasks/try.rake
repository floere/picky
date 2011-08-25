# Tasks for manually testing your engine configuration.
#
desc "Try the given text in the indexer/query (index and category optional)."
task :try, [:text, :index, :category] => :application do |_, options|
  text, index, category = options.text, options.index, options.category

  puts
  fail "\x1b[31mrake try needs a text to try indexing and query preparation\x1b[m, e.g. rake 'try[yourtext]'." unless text

  specific = Picky::Indexes
  specific = specific[index]    if index
  specific = specific[category] if category

  puts "\"#{text}\" is saved in the #{specific.identifier} index as #{specific.tokenizer.tokenize(text.dup).first}"

  puts "\"#{text}\" as a search will be tokenized into #{Picky::Tokenizer.query_default.tokenize(text.dup).first}"
  puts
  puts "(category qualifiers, e.g. title: are removed if they do not exist as a qualifier, so 'toitle:bla' -> 'bla')"
end