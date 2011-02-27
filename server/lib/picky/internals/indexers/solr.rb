# encoding: utf-8
#
require 'rsolr'
module Indexers
  # TODO Deprecated. This should be handled in a special bundle which goes through Solr.
  #
  class Solr

    attr_reader :type, :fields, :solr

    # Takes a Configuration::Type.
    #
    def initialize type
      @type   = type
      @fields = type.solr_fields.map(&:name).map(&:to_sym)
      @solr   = RSolr.connect
    end

    def index
      timed_exclaim "Indexing solr for #{type.name}:#{fields.join(', ')}"
      statement = "SELECT indexed_id, #{fields.join(',')} FROM #{type.snapshot_table_name}"
      
      DB.connect
      results   = DB.connection.execute statement
      
      return unless results # TODO check
      
      type_name = @type.name.to_s
      
      solr.delete_by_query "type:#{type_name}"
      solr.commit
      
      documents = []
      
      results.each do |indexed_id, *values|
        values.each &:downcase!
        documents << hashed(values).merge(id: indexed_id, type: type_name)
      end

      solr.add documents
      solr.commit
      solr.optimize
    end

    def hashed values
      result = {}
      fields.zip(values).each do |field, value|
        result[field] = value
      end
      result
    end

  end
end