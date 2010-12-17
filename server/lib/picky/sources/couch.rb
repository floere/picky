module Sources
  
  # Raised when a Couch source is instantiated without a file.
  #
  # Example:
  #   Sources::Couch.new(:column1, :column2) # without file option
  #
  class NoCouchDBGiven < StandardError; end
  
  # A Couch database source.
  #
  # <b>IMPORTANT NOTE:
  #
  # Since Picky currently only handles integer ids (we're working on this),
  # and CouchDB uses hexadecimal ids, this source automatically
  # recalculates a couch id such as
  # fa3f2577a8dbc6a91d7f9989cdffd38e
  # into
  # 332634873577882511228481564366832915342
  # using String#hex.
  #
  # When using the integer ids in a webapp to get your
  # objects from CouchDB, please do a Integer#to_s(16) on the
  # ids you get from Picky before you use them to get your object from CouchDB.</b>
  # 
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
    
    # If your Couch DB uses UUID keys, use
    #  Sources::Couch.new(:title, keys: Sources::Couch::UUIDKeys.new)
    # Do not forget to reconvert the UUID Key from an integer in the client:
    #  uuid = UUIDTools::UUID.parse_int(id)
    #  uuid.to_s
    #
    class UUIDKeys
      def initialize
        # Tries to require the uuidtools gem.
        #
        begin
          require 'uuidtools'
        rescue LoadError
          puts_gem_missing 'uuidtools', 'UUID keys in a CouchDB source'
          exit 1
        end
      end
      def to_i id
        uuid = UUIDTools::UUID.parse id
        uuid.to_i
      end
    end
    
    # If your Couch DB uses Hex keys, use
    #  Sources::Couch.new(:title, keys: Sources::Couch::HexKeys.new)
    # Do not forget to reconvert the Hex Key from an integer in the client:
    #  id.to_s(16)
    #
    class HexKeys
      def to_i id
        id.hex
      end
    end
    
    # If your Couch DB uses Integer keys, use
    #  Sources::Couch.new(:title, keys: Sources::Couch::IntegerKeys.new)
    #
    class IntegerKeys
      def to_i id
        id
      end
    end
    
    #
    #
    def initialize *category_names, options
      check_gem
      
      Hash === options && options[:url] || raise_no_db_given(category_names)
      @db = RestClient::Resource.new options.delete(:url), options
      
      @to_i_strategy = options.delete(:keys) || HexKeys.new
    end
    
    # Tries to require the rest_client gem.
    #
    def check_gem # :nodoc:
      require 'rest_client'
    rescue LoadError
      puts_gem_missing 'rest-client', 'the CouchDB source'
      exit 1
    end

    # Harvests the data to index.
    #
    # See important note, above.
    #
    @@id_key = '_id'
    def harvest type, category
      category_name = category.from.to_s
      get_data do |doc|
        yield @to_i_strategy.to_i(doc[@@id_key]), doc[category_name] || next
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
