# Tasks for manually testing your engine configuration.
#
namespace :try do
  
  # desc "Try how a given word would be tokenized when indexing (type:category optional)."
  task :index, [:text, :index_and_category] => :application do |_, options|
    text, index_and_category = options.text, options.index_and_category
    
    tokenizer = index_and_category ? Indexes.find(*index_and_category.split(':')).tokenizer : Internals::Tokenizers::Index.default
    
    puts "\"#{text}\" is saved in the index as             #{tokenizer.tokenize(text.dup).to_a}"
  end
  
  # desc "Try how a given word would be tokenized when querying."
  task :query, [:text] => :application do |_, options|
    text = options.text
    
    puts "\"#{text}\" as a query will be preprocessed into #{Internals::Tokenizers::Query.default.tokenize(text.dup).to_a.map(&:to_s).map(&:to_sym)}"
  end
  
  # desc "Try the given text with both the index and the query (type:category optional)."
  task :both, [:text, :index_and_category] => :application do |_, options|
    text, index_and_category = options.text, options.index_and_category
    
    Rake::Task[:"try:index"].invoke text, index_and_category
    Rake::Task[:"try:query"].invoke text
  end
  
end