require 'rsolr'

module Query

  #
  #
  class Solr < Base # :nodoc:all

    attr_reader :server, :index_types

    def initialize *index_types
      @server = RSolr.connect rescue nil
      super *index_types
    end

    #
    #
    def execute tokens, offset = 0
      results = Results::Live.new

      if server
        similar = {}

        new_query = tokens.to_solr_query

        return results if new_query.empty?

        index_types.each do |index|
          begin
            response = server.select q: new_query, fq: "type:#{index.name}", hl: true, :'hl.fl' => '*', :'hl.simple.pre' => '<', :'hl.simple.post' => '>', facet: true
          rescue RSolr::RequestError => re
            return results
          end

          highlighting = response['highlighting']
          possibilities = response['response']['docs'].map do |doc|
            highlights = highlighting[doc['id'].to_s]
            next unless highlights
            selected = doc.select { |key| highlights.has_key?(key) }
            selected.values.join ' '
          end
          possibilities.collect! { |possibility| possibility.strip }.uniq!
          similar[index.name] = possibilities unless possibilities.empty?
        end

        results.add similar: similar
      end

      class << results
        def to_log query
          ?* + super
        end
      end

      results
    end

  end

end