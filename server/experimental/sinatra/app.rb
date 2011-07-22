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
# Sometimes I get:
#   "invalid byte sequence in UTF-8"
#   (handled in the Picky server now)
#

require 'sinatra'
require File.expand_path '../../../lib/picky', __FILE__

# This could be moved into a model file
#   require 'model'
# or similar, of course.
#
class Model
  attr_reader :id, :text
  def initialize id, text
    @id, @text = id, text
  end
end

data = [
  Model.new(1, "Hi"),
  Model.new(2, "It's"),
  Model.new(3, "Mister"),
  Model.new(4, "Model")
]

texts = Indexes::Memory.new :texts do
  source data
  category :text,
           partial: Partial::Substring.new(from: 1),
           similarity: Similarity::DoubleMetaphone.new(3)
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
search = Search.new texts
get '/texts' do
  results = search.search_with_text params[:query], params[:ids] || 20, params[:offset] || 0
  results.to_json
end