# Tasks for manually testing your engine configuration.
#
namespace :try do
  
  # desc "Try how a given word would be tokenized when indexing (type:field optional)."
  task :index, [:text, :index_and_field] => :application do |_, options|
    text, index_and_field = options.text, options.index_and_field
    
    tokenizer = index_and_field ? Indexes.find(*index_and_field.split(':')).tokenizer : Tokenizers::Index.default
    
    puts "\"#{text}\" is index tokenized as #{tokenizer.tokenize(text.dup).to_a}"
  end
  
  # desc "Try how a given word would be tokenized when querying."
  task :query, [:text] => :application do |_, options|
    text = options.text
    
    puts "\"#{text}\" is query tokenized as #{Tokenizers::Query.default.tokenize(text.dup).to_a.map(&:to_s).map(&:to_sym)}"
  end
  
  # desc "Try the given text with both the index and the query (type:field optional)."
  task :both, [:text, :index_and_field] => :application do |_, options|
    text, index_and_field = options.text, options.index_and_field
    
    Rake::Task[:"try:index"].invoke text, index_and_field
    Rake::Task[:"try:query"].invoke text
  end
  
end