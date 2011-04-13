module Sources

  # Raised when a Couch source is instantiated without a file.
  #
  # Example:
  #   Sources::Couch.new(:column1, :column2) # without file option
  #
  class NoCouchDBGiven < StandardError; end

  # A Couch database source.
  #
  # Options:
  # * url
  # and all the options of a <tt>RestClient::Resource</tt>.
  # See http://github.com/archiloque/rest-client.
  #
  # Examples:
  #  Sources::Couch.new(:title, :author, :isbn, url:'localhost:5984')
  #  Sources::Couch.new(:title, :author, :isbn, url:'localhost:5984', user:'someuser', password:'somepassword')
  #
  class Couch < Base

    #
    #
    def initialize *category_names, options
      check_gem

      Hash === options && options[:url] || raise_no_db_given(category_names)

      @db = RestClient::Resource.new options.delete(:url), options

      key_format   = options.delete :key_format
      @key_format  = key_format && key_format.to_sym || :to_sym
    end

    def to_s
      self.class.name
    end

    # Tries to require the rest_client gem.
    #
    def check_gem # :nodoc:
      require 'rest_client'
    rescue LoadError
      warn_gem_missing 'rest-client', 'the CouchDB source'
      exit 1
    end

    # Harvests the data to index.
    #
    # See important note, above.
    #
    @@id_key = '_id'
    def harvest category
      category_name = category.from.to_s
      get_data do |doc|
        yield doc[@@id_key], doc[category_name] || next
      end
    end

    def get_data &block # :nodoc:
      resp = @db['_all_docs?include_docs=true'].get
      JSON.parse(resp)['rows'].
        map{|row| row['doc']}.
        each &block
    end

    def raise_no_db_given category_names # :nodoc:
      raise NoCouchDBGiven.new(category_names.join(', '))
    end
  end
end
