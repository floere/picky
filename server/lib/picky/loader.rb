module Picky

  # Loads the search engine and it
  #
  module Loader

    class << self

      # Reloads the whole app.
      # First itself, then the app.
      #
      def reload app_file = 'app'
        Dir.chdir Picky.root
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
      def load_relative *filenames_without_rb
        filenames_without_rb.each do |filename_without_rb|
          Kernel.load File.join(File.dirname(__FILE__), "#{filename_without_rb}.rb")
        end
      end

      # Load a user file.
      #
      def load_user filename
        Kernel.load File.join(Picky.root, "#{filename}.rb")
      end

      # Load the user's application.
      #
      def load_application file = 'app'
        load_user file
      rescue LoadError => e
        exclaim "\nBy default, Picky needs/loads the <Picky.root>/app.rb file as the app.\n\n"
        raise e
      end
      
      # Loads the compiled C code.
      #
      # Note: Picky already tries to compile
      # when installing the gem.
      #
      def load_c_code
        require_relative '../try_compile'
      end
      def load_extensions
        load_relative 'extensions/object',
                      'extensions/array',
                      'extensions/symbol',
                      'extensions/string',
                      'extensions/module',
                      'extensions/class'
      end
      def load_helpers
        load_relative 'helpers/measuring',
                      'helpers/indexing',
                      'helpers/identification',
                      'splitter',
                      'optimizers',
                      'optimizers/memory/array_deduplicator'
      end
      def load_index_generation_strategies
        load_relative 'indexers/base',
                      'indexers/serial',
                      'indexers/parallel'
        
        load_relative 'generators/strategy'
        
        # Partial index generation strategies.
        #
        load_relative 'generators/partial/strategy',
                      'generators/partial/none',
                      'generators/partial/substring',
                      'generators/partial/postfix',
                      'generators/partial/infix',
                      'generators/partial/default'
        
        # Weight index generation strategies.
        #
        load_relative 'generators/weights/strategy',
                      'generators/weights/stub',
                      'generators/weights/dynamic',
                      'generators/weights/constant',
                      'generators/weights/logarithmic',
                      'generators/weights/default'
        
        # Similarity index generation strategies.
        #
        load_relative 'generators/similarity/strategy',
                      'generators/similarity/none',
                      'generators/similarity/phonetic',
                      'generators/similarity/metaphone',
                      'generators/similarity/double_metaphone',
                      'generators/similarity/soundex',
                      'generators/similarity/default'
      end
      
      # Loads the index store handling.
      #
      def load_index_stores
        load_relative 'backends/helpers/file',
                      'backends/backend'

        load_relative 'backends/prepared/text'

        load_relative 'backends/memory',
                      'backends/memory/basic',
                      'backends/memory/marshal',
                      'backends/memory/json'

        load_relative 'backends/file',
                      'backends/file/basic',
                      'backends/file/json'

        load_relative 'backends/redis',
                      'backends/redis/directly_manipulable',
                      'backends/redis/basic',
                      'backends/redis/list',
                      'backends/redis/string',
                      'backends/redis/float'

        load_relative 'backends/sqlite',
                      'backends/sqlite/directly_manipulable',
                      'backends/sqlite/basic',
                      'backends/sqlite/array',
                      'backends/sqlite/value',
                      'backends/sqlite/string_key_array',
                      'backends/sqlite/integer_key_array'
      end
      
      # Indexing and Indexed things.
      #
      def load_indexes
        load_relative 'bundle',
                      'bundle_indexing',
                      'bundle_indexed',
                      'bundle_realtime'
      end
      
      # Index wrappers.
      #
      def load_wrappers
        load_relative 'category/location'

        load_relative 'wrappers/bundle/delegators',
                      'wrappers/bundle/wrapper',
                      'wrappers/bundle/calculation',
                      'wrappers/bundle/location',
                      'wrappers/bundle/exact_partial'
      end
      
      # Query combinations, qualifiers, weigher.
      #
      def load_query
        load_relative 'query/combination',
                      'query/combinations',
                      'query/combination/or'

        load_relative 'query/allocation',
                      'query/allocations'

        load_relative 'query/boosts'

        load_relative 'query/indexes',
                      'query/indexes/check'
      end
      
      # Loads the internal parts of the framework.
      # (Not for the user)
      #
      def load_framework_internals
        load_c_code
        load_extensions
        load_helpers
        load_relative 'pool'
        load_relative 'calculations/location' # Calculations
        load_index_generation_strategies
        load_index_stores
        load_indexes
        load_wrappers
        load_relative 'query/token' # Token related.
        load_relative 'query/tokens'
        load_relative 'query/or'
        load_query
      end
      
      # All things API related.
      #
      def load_api
        load_relative 'api/tokenizer/character_substituter',
                      'api/tokenizer/stemmer',
                      'api/search/boost'
      end
      
      def load_logging
        load_relative 'loggers/silent',
                      'loggers/concise',
                      'loggers/verbose',
                      'loggers/default'
      end
      
      def load_generators
        load_relative 'generators/weights'
        load_relative 'generators/partial'
        load_relative 'generators/similarity'
        load_relative 'generators/aliases'
      end
      
      def load_inner_api
        load_relative 'qualifier_mapper'
        
        load_relative 'category',
                      'category_indexed',
                      'category_indexing',
                      'category_realtime',
                      'category_convenience'

        load_relative 'categories',
                      'categories_indexed',
                      'categories_indexing',
                      'categories_realtime',
                      'categories_convenience'

        load_relative 'indexes',
                      'indexes_indexed',
                      'indexes_indexing',
                      'indexes_convenience'
        
        load_relative 'index',
                      'index_indexed',
                      'index_indexing',
                      'index_realtime',
                      'index_facets',
                      'index_convenience'
      end
      
      def load_results
        load_relative 'results',
                      'results/exact_first'
      end
      
      def load_search
        load_relative 'search',
                      'search_facets'
      end
      
      def load_interfaces
        load_relative 'interfaces/live_parameters/master_child',
                      'interfaces/live_parameters/unicorn'
      end
      
      # Loads the user interface parts.
      #
      def load_user_interface
        load_api
        load_logging
        load_relative 'source'
        load_relative 'tokenizer/regexp_wrapper'
        load_relative 'tokenizer'
        # load_relative 'rack/harakiri' # Needs to be explicitly loaded/required.
        load_relative 'character_substituters/base'
        load_relative 'character_substituters/west_european'
        load_relative 'character_substituters/polish'
        load_relative 'splitters/automatic'
        load_generators
        load_inner_api
        load_results
        load_search
        load_interfaces
        load_relative 'scheduler'
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
