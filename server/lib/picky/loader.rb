module Picky

  # Loads the search engine and it
  #
  module Loader # :nodoc:all

    class << self

      # Reloads the whole app.
      # First itself, then the app.
      #
      def reload app_file = 'app'
        Dir.chdir PICKY_ROOT
        exclaim 'Reloading loader.'
        load_self
        exclaim 'Reloading framework.'
        load_framework
        exclaim "Reloading application in #{File.expand_path(app_file)}."
        load_application app_file
      end
      alias load reload

      # Loads this file anew.
      #
      def load_self
        Kernel.load __FILE__
      end

      # Load a file relative to this.
      #
      def load_relative filename_without_rb
        Kernel.load File.join(File.dirname(__FILE__), "#{filename_without_rb}.rb")
      end

      # Load a user file.
      #
      def load_user filename
        Kernel.load File.join(PICKY_ROOT, "#{filename}.rb")
      end

      # Load the user's application.
      #
      def load_application file = 'app'
        load_user file
      rescue LoadError => e
        exclaim "\nBy default, Picky needs/loads the PICKY_ROOT/app.rb file as the app.\n\n"
        raise e
      end

      # Loads the internal parts of the framework.
      # (Not for the user)
      #
      def load_framework_internals
        # Load compiled C code.
        #
        load_relative 'ext/maybe_compile'

        # Load extensions.
        #
        load_relative 'extensions/object'
        load_relative 'extensions/array'
        load_relative 'extensions/symbol'
        load_relative 'extensions/string'
        load_relative 'extensions/module'
        load_relative 'extensions/class'
        load_relative 'extensions/hash'

        # Requiring Helpers
        #
        load_relative 'helpers/measuring'
        load_relative 'helpers/indexing'

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
        load_relative 'generators/partial/postfix'
        load_relative 'generators/partial/infix'
        load_relative 'generators/partial/default'

        # Weight index generation strategies.
        #
        load_relative 'generators/weights/strategy'
        load_relative 'generators/weights/stub'
        load_relative 'generators/weights/dynamic'
        load_relative 'generators/weights/constant'
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

        # Index store handling.
        #
        load_relative 'backends/helpers/file'
        load_relative 'backends/backend'

        load_relative 'backends/prepared/text'

        load_relative 'backends/memory'
        load_relative 'backends/memory/basic'
        load_relative 'backends/memory/marshal'
        load_relative 'backends/memory/json'

        load_relative 'backends/file'
        load_relative 'backends/file/basic'
        load_relative 'backends/file/json'

        load_relative 'backends/redis'
        load_relative 'backends/redis/directly_manipulable'
        load_relative 'backends/redis/basic'
        load_relative 'backends/redis/list'
        load_relative 'backends/redis/string'
        load_relative 'backends/redis/float'

        load_relative 'backends/sqlite'
        load_relative 'backends/sqlite/directly_manipulable'
        load_relative 'backends/sqlite/basic'
        load_relative 'backends/sqlite/array'
        load_relative 'backends/sqlite/value'
        load_relative 'backends/sqlite/string_key_array'
        load_relative 'backends/sqlite/integer_key_array'

        # Indexing and Indexed things.
        #
        load_relative 'bundle'
        load_relative 'bundle_indexing'
        load_relative 'bundle_indexed'
        load_relative 'bundle_realtime'

        # Wrappers.
        #
        load_relative 'category/location'

        load_relative 'wrappers/bundle/delegators'
        load_relative 'wrappers/bundle/wrapper'
        load_relative 'wrappers/bundle/calculation'
        load_relative 'wrappers/bundle/location'
        load_relative 'wrappers/bundle/exact_partial'

        # Tokens.
        #
        load_relative 'query/token'
        load_relative 'query/tokens'

        # Query combinations, qualifiers, weigher.
        #
        load_relative 'query/combination'
        load_relative 'query/combinations'

        load_relative 'query/allocation'
        load_relative 'query/allocations'

        load_relative 'query/qualifier_category_mapper'

        load_relative 'query/weights'

        load_relative 'query/indexes'
        load_relative 'query/indexes_check'
      end
      # Loads the user interface parts.
      #
      def load_user_interface
        # Load API parts.
        #
        load_relative 'api/tokenizer'
        load_relative 'api/tokenizer/character_substituter'
        load_relative 'api/source'

        # Tokenizer.
        #
        load_relative 'tokenizer'

        # Load harakiri.
        #
        load_relative 'rack/harakiri'

        # Character Substituters
        #
        load_relative 'character_substituters/west_european'

        # Convenience accessors for generators.
        #
        load_relative 'generators/aliases'

        # API.
        #
        load_relative 'category'
        load_relative 'category_indexed'
        load_relative 'category_indexing'
        load_relative 'category_realtime'
        load_relative 'category_convenience'

        load_relative 'categories'
        load_relative 'categories_indexed'
        load_relative 'categories_indexing'
        load_relative 'categories_realtime'
        load_relative 'categories_convenience'

        load_relative 'indexes'
        load_relative 'indexes_indexed'
        load_relative 'indexes_indexing'
        load_relative 'indexes_convenience'

        load_relative 'index'
        load_relative 'index_indexed'
        load_relative 'index_indexing'
        load_relative 'index_realtime'
        load_relative 'index_convenience'

        # Results.
        #
        load_relative 'results'
        load_relative 'results/exact_first'

        # Search.
        #
        load_relative 'search'

        # Interfaces
        #
        load_relative 'interfaces/live_parameters/master_child'
        load_relative 'interfaces/live_parameters/unicorn'

        # Load tools. Load specifically?
        #
        load_relative 'scheduler'

        # Load migration notices.
        #
        load_relative 'migrations/from_30_to_31'
      end

      # Loads the framework.
      #
      def load_framework
        load_framework_internals
        load_user_interface
      end

    end

  end

end
