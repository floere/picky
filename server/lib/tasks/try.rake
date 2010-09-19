# Tasks for manually testing your engine configuration.
#
namespace :try do
  
  desc "Try how a given word would be tokenized when indexing (field name optional)."
  task :index, [:text, :field] => :framework do |_, options|
    text, field = options.text, options.field
    
    if field
      # TODO
    else
      puts "\"#{text}\" is index tokenized as #{Tokenizers::Index.new.tokenize(text).to_a}"
    end
  end
  
  desc "Try how a given word would be tokenized when querying."
  task :query, [:text] => :framework do |_, options|
    text = options.text
    
    puts "\"#{text}\" is query tokenized as #{Tokenizers::Query.new.tokenize(text).to_a}"
  end
  
end