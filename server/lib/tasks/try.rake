# Tasks for manually testing your engine configuration.
#
namespace :try do
  
  desc "try Tasks let you try out your indexing and querying specifications."
  task
  
  desc "Try how a given word would be tokenized when indexing (field name optional)."
  task :index, [:text, :field] => :application do |_, options|
    text, field = options.text, options.field
    
    if field
      # TODO
    else
      puts "\"#{text}\" is index tokenized as #{Tokenizers::Index.new.tokenize(text).to_a}"
    end
  end
  
  desc "Try how a given word would be tokenized when querying."
  task :query, [:text] => :application do |_, options|
    text = options.text
    
    puts "\"#{text}\" is query tokenized as #{Tokenizers::Query.new.tokenize(text).to_a}"
  end
  
  desc "Try the given text with both the index and the query (field name optional)."
  task :both, [:text, :field] => :application do |_, options|
    text, field = options.text, options.field
    
    Rake::Task[:"try:index"].invoke text, field
    Rake::Task[:"try:query"].invoke text
  end
  
end