# Experiment 1: Route using Sinatra.
#
# ruby sinatra.rb
#
# curl 'localhost:4567/hi?query=test'
#
module Picky

  class Search
    def initialize *indexes
      @indexes = indexes
    end
    def search_with_text text
      "Searched for #{text} in #{@indexes.join(', ')}."
    end
  end

  module Sinatra
    def search routings
      routings.each do |pattern, target_search|
        get pattern do
          target_search.search_with_text params[:query]
        end
      end
    end
  end

end


require 'sinatra'

include Picky::Sinatra

search '/hi'    => Picky::Search.new(:some_index, :other_index),
       '/hello' => Picky::Search.new(:that_index)