module Sources
  
  # Describes a Couch database
  # Give it a databse url and optionally username and password
  #
  
  class NoCouchDBGiven < StandardError; end

  class Couch < Base
    
    def initialize *category_names, options
      check_gem
      Hash === options && options[:url] || raise_no_db_given(category_names)
      @db = RestClient::Resource.new options.delete(:url), options
    end
    
    def check_gem
      require 'rest_client'
    rescue LoadError
      puts "Rest-client gem missing!\nTo use the CouchDB source, you need to:\n  1. Add the following line to Gemfile:\n     gem 'rest-client'\n  2. Then, run:\n     bundle update\n"
      exit 1
    end

    # Harvests the data to index.
    #
    def harvest type, category
      category_name = category.from.to_s
      get_data do |doc|
        yield doc['_id'].to_i, doc[category_name] || next
      end
    end

    def get_data &block
      resp = @db['_all_docs?include_docs=true'].get
      JSON.parse(resp)['rows'].
        map{|row| row['doc']}.
        each &block
    end
    
    def raise_no_db_given category_names
      raise NoCouchDBGiven.new(category_names.join(', '))
    end
  end
end
