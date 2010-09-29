# encoding: utf-8
#
require 'rsolr'
module Indexers
  # This is an indexer in its own right.
  #
  # TODO Perhaps merge with the existing indexer.
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

    # TODO Rewrite such that it works in batches.
    #
    def index
      puts "#{Time.now}: Indexing solr for #{type.name}:#{fields.join(', ')}"
      statement = "SELECT indexed_id, #{fields.join(',')} FROM #{type.snapshot_table_name}"
      
      # TODO Rewrite.
      #
      DB.connect
      results   = DB.connection.execute statement

      return unless results # TODO check

      type_name = @type.name.to_s

      solr.delete_by_query "type:#{type_name}"
      solr.commit

      documents = []

      results.each do |indexed_id, *values|
        values.each &:downcase!
        documents << hashed(values).merge(:id => indexed_id, :type => type_name)
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