# Run with:
#   bundle exec ruby app.rb
#
# Example queries:
#   curl 'localhost:4567/texts?query=hi'
#   curl 'localhost:4567/texts?query=m'
#   curl 'localhost:4567/texts?query=ho~'
#
# With the command line interface:
#   picky search localhost:4567/texts
#

require 'sinatra'
require File.expand_path '../../../lib/picky', __FILE__

require File.expand_path '../model', __FILE__

texts = Picky::Indexes::Memory.new :texts do
  source   { Model.all }
  category :text,
           partial: Picky::Partial::Substring.new(from: 1),
           similarity: Picky::Similarity::DoubleMetaphone.new(3)
end

# Index and load on startup.
#
texts.index
texts.reload

# Reindex on USR1 signal.
#
Signal.trap('USR1') do
  texts.reindex # kill -USR1 <pid>
end

# Route to a search, return json.
#
search = Picky::Search.new texts
get '/texts' do
  results = search.search_with_text params[:query], params[:ids] || 20, params[:offset] || 0
  results.to_json
end