module Sources

  # Raised when a Mongo source is instantiated without a valid uri.
	#
	# Important!
  # You have to start your mongodb with --rest in order to use
  # the rest / http interface 
	#
  class NoMongoDBGiven < StandardError; end

  # A Mongo database source.
  #
  # Options:
  # * url, db
  # Example:
  #   Sources::Mongo.new(:collection1, :collection2, :url => 'localhost:28017', :db => 'testdatabase')
	# Be sure to escape the URL properly, e.g. # => %23 in the databasename if needed
	#
  # and all the options of a <tt>RestClient::Resource</tt>.
  # See http://github.com/archiloque/rest-client.
  #

  class Mongo < Base
		@@id_key = '_id'
    #
    #
    def initialize *category_names, options
      check_gem
	
			unless options.try(:[], :url) && options.try(:[], :db)
				raise_no_db_given(category_names)
			end
		
		  @db = RestClient::Resource.new options.delete(:url), options
			@database = options.delete(:db)
		  @key_format  = options.try(:[], :key_format).try(:to_sym) || :to_sym
		end

    # Tries to require the rest_client gem.
    #
    def check_gem # :nodoc:
      require 'rest_client'
    rescue LoadError
      warn_gem_missing 'rest-client', 'the MongoDB source'
      exit 1
    end

		# Fetches the data, @limit=0 will return all records 
		#
		# Limit is set to 0 by default - all collection entries will be send
		# If want to limit the results, set to to any other number, e.g. limit=15
		# to return only 15 entries
		#
		def harvest category
			collection = category.from.to_s || category.index_name.to_s
			resp = @db["/#{@database}/#{category.index_name.to_s}/?@limit=0"].get
			JSON.parse(resp)['rows'].each do |row|
				index_key = row.fetch(@@id_key).values
				row.delete(@@id_key)
				text = row[collection].to_s
				next unless text
				yield index_key, text
			end
		end

    def raise_no_db_given category_names # :nodoc:
      raise NoMongoDBGiven.new(category_names.join(', '))
    end
  end
end
