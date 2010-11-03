module Sources
  
  # Describes a Couch database
  # Give it a databse url and optionally username and password
  #
  
  class NoCouchDBGiven < StandardError; end

  class COUCH < Base
    
    def initialize *field_names, options
      require 'rest_client'
      Hash === options && options[:url] || raise_no_db_given(field_names)
      @db = RestClient::Resource.new options.delete(:url), options
    end

    # Harvests the data to index.
    #
    def harvest type, field
      get_data do |doc|
        yield doc['_id'].to_i, doc[field.name.to_s] || next
      end
    end

    def get_data &block
      resp = @db['_all_docs?include_docs=true'].get
      JSON.parse(resp)['rows'].
        map{|row| row['doc']}.
        each &block
    end

    def raise_no_db_given field_names
      raise NoCouchDBGiven.new field_names.join(', ')
    end
  end
end
