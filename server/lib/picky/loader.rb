# Loads the search engine and itself.
#
module Loader # :nodoc:all

  # Reloads the whole app.
  # First itself, then the app.
  #
  def self.reload
    Dir.chdir(PICKY_ROOT)
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

  def self.load_relative filename_without_rb
    load File.join(File.dirname(__FILE__), "#{filename_without_rb}.rb")
  end
  def self.load_internals filename_without_rb
    load File.join(File.dirname(__FILE__), "internals/#{filename_without_rb}.rb")
  end

  def self.load_user filename
    load File.join(PICKY_ROOT, "#{filename}.rb")
  end
  def self.load_user_lib filename
    load_user File.join('lib', filename)
  end
  def self.load_all_user_in dirname
    Dir[File.join(PICKY_ROOT, dirname, '**', '*.rb')].each do |filename|
      load filename
    end
  end

  # Load the user's application.
  #
  def self.load_application
    # Add lib dir to load path.
    #
    # add_lib_dir

    # Picky autoloading.
    #
    begin
      load_all_user_in 'lib/initializers'
      load_all_user_in 'lib/tokenizers'
      load_all_user_in 'lib/indexers'
      load_all_user_in 'lib/query'
    rescue NameError => name_error
      namespaced_class_name = name_error.message.gsub /^uninitialized\sconstant\s/, ''
      load_user_lib namespaced_class_name.underscore # Try it once.
      retry
    end

    # Prepare the application for reload.
    #
    # TODO Application.prepare_for_reload

    # Load the user's config.
    #
    load_user 'app/logging'
    load_user 'app/application'

    # Finalize the applications.
    #
    Application.finalize_apps

    # TODO Rewrite
    #
    Internals::Query::Qualifiers.instance.prepare

    exclaim "Application #{Application.apps.map(&:name).join(', ')} loaded."
  end

  # Loads the internal parts of the framework.
  # (Not for the user)
  #
  def self.load_framework_internals
    load_relative 'internals'

    # Load compiled C code.
    #
    load_internals 'ext/maybe_compile'

    # Load extensions.
    #
    load_internals 'extensions/object'
    load_internals 'extensions/array'
    load_internals 'extensions/symbol'
    load_internals 'extensions/module'
    load_internals 'extensions/hash'

    # Requiring Helpers
    #
    load_internals 'helpers/measuring'

    # Calculations.
    #
    load_internals 'calculations/location'

    # Index generation strategies.
    #
    load_internals 'indexers/base'
    load_internals 'indexers/serial'
    load_internals 'indexers/parallel'

    # Generators.
    #
    load_internals 'generators/strategy'

    # Partial index generation strategies.
    #
    load_internals 'generators/partial/strategy'
    load_internals 'generators/partial/none'
    load_internals 'generators/partial/substring'
    load_internals 'generators/partial/default'

    # Weight index generation strategies.
    #
    load_internals 'generators/weights/strategy'
    load_internals 'generators/weights/logarithmic'
    load_internals 'generators/weights/default'

    # Similarity index generation strategies.
    #
    load_internals 'generators/similarity/strategy'
    load_internals 'generators/similarity/none'
    load_internals 'generators/similarity/phonetic'
    load_internals 'generators/similarity/metaphone'
    load_internals 'generators/similarity/double_metaphone'
    load_internals 'generators/similarity/soundex'
    load_internals 'generators/similarity/default'

    # Index generators.
    #
    load_internals 'generators/base'
    load_internals 'generators/partial_generator'
    load_internals 'generators/weights_generator'
    load_internals 'generators/similarity_generator'

    # Shared index elements.
    #
    load_internals 'shared/category'

    # Index store handling.
    #
    load_internals 'index/backend'

    load_internals 'index/redis'
    load_internals 'index/redis/basic'
    load_internals 'index/redis/list_hash'
    load_internals 'index/redis/string_hash'

    load_internals 'index/file/basic'
    load_internals 'index/file/text'
    load_internals 'index/file/marshal'
    load_internals 'index/file/json'

    load_internals 'index/files'

    # Indexing and Indexed things.
    #
    load_internals 'indexing/bundle/super_base' # TODO Remove.
    load_internals 'indexing/bundle/base'
    load_internals 'indexing/bundle/memory'
    load_internals 'indexing/bundle/redis'
    load_internals 'indexing/category'
    # load_internals 'indexing/categories'
    load_internals 'indexing/index'

    load_internals 'indexing/wrappers/category/location'

    load_internals 'indexed/bundle/base'
    load_internals 'indexed/bundle/memory'
    load_internals 'indexed/bundle/redis'
    load_internals 'indexed/category'
    load_internals 'indexed/categories'
    load_internals 'indexed/index'

    load_internals 'indexed/wrappers/exact_first'

    # Bundle Wrapper
    #
    load_internals 'indexed/wrappers/bundle/wrapper'
    load_internals 'indexed/wrappers/bundle/calculation'
    load_internals 'indexed/wrappers/bundle/location'

    load_internals 'indexed/wrappers/category/location'

    # Tokens.
    #
    load_internals 'query/token'
    load_internals 'query/tokens'

    # Tokenizers types.
    #
    load_internals 'tokenizers/base'
    load_internals 'tokenizers/index'
    load_internals 'tokenizers/query'

    # Query combinations, qualifiers, weigher.
    #
    load_internals 'query/combination'
    load_internals 'query/combinations/base'
    load_internals 'query/combinations/memory'
    load_internals 'query/combinations/redis'

    load_internals 'query/allocation'
    load_internals 'query/allocations'

    load_internals 'query/qualifiers'

    load_internals 'query/weights'

    load_internals 'query/indexes'

    # Configuration.
    #
    # load_internals 'configuration/index'

    # Adapters.
    #
    load_internals 'adapters/rack/base'
    load_internals 'adapters/rack/query'
    load_internals 'adapters/rack/live_parameters'
    load_internals 'adapters/rack'

    # Routing.
    #
    load_internals 'frontend_adapters/rack'
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

    # Signal handling
    #
    load_relative 'signals'

    # Logging.
    #
    load_relative 'loggers/search'

    # Convenience accessors for generators.
    #
    load_relative 'generators/aliases'

    # API.
    #
    load_relative 'index/base'
    load_relative 'index/memory'
    load_relative 'index/redis'

    load_relative 'indexing/indexes'
    load_relative 'indexed/indexes'

    load_relative 'index_bundle'
    load_relative 'aliases'

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
