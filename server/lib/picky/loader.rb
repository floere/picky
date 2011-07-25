module Picky

  # Loads the search engine and itself.
  #
  module Loader # :nodoc:all

    # Reloads the whole app.
    # First itself, then the app.
    #
    def self.reload
      Dir.chdir PICKY_ROOT
      exclaim 'Reloading loader.'
      load_self
      exclaim 'Reloading framework.'
      load_framework
      exclaim 'Reloading application.'
      load_application
    end

    # Loads this file anew.
    #
    def self.load_self
      exclaim 'Loader loading itself.'
      load __FILE__
    end

    # Load a file relative to this.
    #
    def self.load_relative filename_without_rb
      load File.join(File.dirname(__FILE__), "#{filename_without_rb}.rb")
    end

    # Load a user file.
    #
    def self.load_user filename
      file_name = File.join PICKY_ROOT, "#{filename}.rb"
      load file_name if File.exists? file_name
    end

    # Load the user's application.
    #
    def self.load_application
      Application.reload
    end

    # Loads the internal parts of the framework.
    # (Not for the user)
    #
    def self.load_framework_internals
      # Load compiled C code.
      #
      load_relative 'ext/maybe_compile'

      # Load extensions.
      #
      load_relative 'extensions/object'
      load_relative 'extensions/array'
      load_relative 'extensions/symbol'
      load_relative 'extensions/module'
      load_relative 'extensions/class'
      load_relative 'extensions/hash'

      # Requiring Helpers
      #
      load_relative 'helpers/measuring'

      # Calculations.
      #
      load_relative 'calculations/location'

      # Index generation strategies.
      #
      load_relative 'indexers/base'
      load_relative 'indexers/serial'
      load_relative 'indexers/parallel'

      # Generators.
      #
      load_relative 'generators/strategy'

      # Partial index generation strategies.
      #
      load_relative 'generators/partial/strategy'
      load_relative 'generators/partial/none'
      load_relative 'generators/partial/substring'
      load_relative 'generators/partial/default'

      # Weight index generation strategies.
      #
      load_relative 'generators/weights/strategy'
      load_relative 'generators/weights/logarithmic'
      load_relative 'generators/weights/default'

      # Similarity index generation strategies.
      #
      load_relative 'generators/similarity/strategy'
      load_relative 'generators/similarity/none'
      load_relative 'generators/similarity/phonetic'
      load_relative 'generators/similarity/metaphone'
      load_relative 'generators/similarity/double_metaphone'
      load_relative 'generators/similarity/soundex'
      load_relative 'generators/similarity/default'

      # Index generators.
      #
      load_relative 'generators/base'
      load_relative 'generators/partial_generator'
      load_relative 'generators/weights_generator'
      load_relative 'generators/similarity_generator'

      # Index store handling.
      #
      load_relative 'backend/base'

      load_relative 'backend/redis'
      load_relative 'backend/redis/basic'
      load_relative 'backend/redis/list_hash'
      load_relative 'backend/redis/string_hash'

      load_relative 'backend/file/basic'
      load_relative 'backend/file/text'
      load_relative 'backend/file/marshal'
      load_relative 'backend/file/json'

      load_relative 'backend/files'

      # Indexing and Indexed things.
      #
      load_relative 'bundle'

      load_relative 'indexing/bundle/base'
      load_relative 'indexing/bundle/memory'
      load_relative 'indexing/bundle/redis'

      load_relative 'indexing/wrappers/category/location'

      load_relative 'indexed/bundle/base'
      load_relative 'indexed/bundle/memory'
      load_relative 'indexed/bundle/redis'

      load_relative 'indexed/wrappers/exact_first'

      # Bundle Wrapper
      #
      load_relative 'indexed/wrappers/bundle/wrapper'
      load_relative 'indexed/wrappers/bundle/calculation'
      load_relative 'indexed/wrappers/bundle/location'

      load_relative 'indexed/wrappers/category/location'

      # Tokens.
      #
      load_relative 'query/token'
      load_relative 'query/tokens'

      # Tokenizers types.
      #
      load_relative 'tokenizers/base'
      load_relative 'tokenizers/index'
      load_relative 'tokenizers/query'

      # Query combinations, qualifiers, weigher.
      #
      load_relative 'query/combination'
      load_relative 'query/combinations/base'
      load_relative 'query/combinations/memory'
      load_relative 'query/combinations/redis'

      load_relative 'query/allocation'
      load_relative 'query/allocations'

      load_relative 'query/qualifier_category_mapper'

      load_relative 'query/weights'

      load_relative 'query/indexes'

      # Configuration.
      #
      # load_internals 'configuration/index'

      # Adapters.
      #
      load_relative 'adapters/rack/base'
      load_relative 'adapters/rack/search'
      load_relative 'adapters/rack/live_parameters'
      load_relative 'adapters/rack'

      # Routing.
      #
      load_relative 'frontend_adapters/rack'
    end
    # Loads the user interface parts.
    #
    def self.load_user_interface
      # Load harakiri.
      #
      load_relative 'rack/harakiri'

      # Errors.
      #
      load_relative 'no_source_specified_exception'

      # Load analyzer.
      #
      load_relative 'analyzer'

      # Character Substituters
      #
      load_relative 'character_substituters/west_european'

      # Logging.
      #
      load_relative 'loggers/search'

      # Convenience accessors for generators.
      #
      load_relative 'generators/aliases'

      # API.
      #
      load_relative 'category'
      load_relative 'category_indexed'
      load_relative 'category_indexing'

      load_relative 'categories'
      load_relative 'categories_indexed'
      load_relative 'categories_indexing'

      load_relative 'indexes'
      load_relative 'indexes_indexed'
      load_relative 'indexes_indexing'

      load_relative 'indexes/index'
      load_relative 'indexes/index_indexed'
      load_relative 'indexes/index_indexing'
      load_relative 'indexes/memory'
      load_relative 'indexes/redis'

      # Results.
      #
      load_relative 'results'

      # Search.
      #
      load_relative 'search'
      load_relative 'query'
      #
      # load_relative 'query/solr'

      # Sources.
      #
      load_relative 'sources/base'
      load_relative 'sources/db'
      load_relative 'sources/csv'
      load_relative 'sources/delicious'
      load_relative 'sources/couch'
      load_relative 'sources/mongo'

      load_relative 'sources/wrappers/base'
      load_relative 'sources/wrappers/location'

      # Interfaces
      #
      load_relative 'interfaces/live_parameters'

      # Application.
      #
      load_relative 'application'

      # Load tools. Load in specific case?
      #
      load_relative 'cores'
    end

    # Loads the framework.
    #
    def self.load_framework
      load_framework_internals
      load_user_interface
    end

  end

end