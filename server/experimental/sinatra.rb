# Experiment 1: Route using Sinatra.
#

module Picky

  class Search

    def search_with_text text
      text
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

search '/hi' => Picky::Search.new,
       '/hello' => Picky::Search.new