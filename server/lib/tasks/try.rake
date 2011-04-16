# Tasks for manually testing your engine configuration.
#
namespace :try do

  # desc "Try how a given word would be tokenized when indexing (type:category optional)."
  task :index, [:text, :index, :category] => :application do |_, options|
    text, index, category = options.text, options.index, options.category

    tokenizer = category ? Indexes.find(index, category).tokenizer : Internals::Tokenizers::Index.default

    puts "\"#{text}\" is saved in the index as              #{tokenizer.tokenize(text.dup).to_a}"
  end

  # desc "Try how a given word would be tokenized when querying."
  task :query, [:text] => :application do |_, options|
    text = options.text

    puts "\"#{text}\" as a search will be preprocessed into #{Internals::Tokenizers::Query.default.tokenize(text.dup).to_a.map(&:to_s).map(&:to_sym)}"
    puts
    puts "(category qualifiers, e.g. title: are removed if they do not exist as a qualifier, so 'toitle:bla' -> 'bla')"
  end

  # desc "Try the given text with both the index and the query (type:category optional)."
  task :both, [:text, :index, :category] => :application do |_, options|
    text, index, category = options.text, options.index, options.category

    puts
    fail "\x1b[31mrake try needs a text to try indexing and query preparation\x1b[m, e.g. rake 'try[yourtext]'." unless text

    Rake::Task[:"try:index"].invoke text, index, category
    Rake::Task[:"try:query"].invoke text
  end

end