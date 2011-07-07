# Run with:
#   bundle exec unicorn
#
# Example queries:
#   curl 'localhost:8080/texts?query=hi'
#   curl 'localhost:8080/texts?query=m'
#   curl 'localhost:8080/texts?query=ho~'
#
# With the command line interface:
#   picky search localhost:8080/texts
#
# Sometimes I get:
#   "invalid byte sequence in UTF-8"
#   (handled in the Picky server now)
#

require 'sinatra'
require File.expand_path '../../../lib/picky', __FILE__

class Model
  attr_reader :id, :text
  def initialize id, text
    @id, @text = id, text
  end
  def self.all
    [
      new(1, "Hi"),
      new(2, "It's"),
      new(3, "Mister"),
      new(4, "Model")
    ]
  end
end

class UnicornApp < Sinatra::Application

  texts = Index::Memory.new :texts do
    source   Model.all
    category :text,
             partial: Partial::Substring.new(from: 1),
             similarity: Similarity::DoubleMetaphone.new(3)
  end

  texts.index
  texts.reload


  search = Search.new texts

  get '/texts' do
    results = search.search_with_text params[:query]
    results.to_json
  end

end