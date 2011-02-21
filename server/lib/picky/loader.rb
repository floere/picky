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
  
  def self.require_relative filename
    require File.join(File.dirname(__FILE__), filename)
  end
  def self.load_relative filename_without_rb
    load File.join(File.dirname(__FILE__), "#{filename_without_rb}.rb")
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
    
    # Load the user's config.
    #
    load_user 'app/logging'
    load_user 'app/application'
    
    # Finalize the applications.
    #
    # TODO Problem: Reload Routes. Throw them all away and do them again?
    #
    Application.finalize_apps
    
    # TODO Rewrite
    #
    Query::Qualifiers.instance.prepare
    
    exclaim "Application #{Application.apps.map(&:name).join(', ')} loaded."
  end
  
  # Loads the framework.
  #
  def self.load_framework
    # Load compiled C code.
    #
    require_relative 'ext/maybe_compile'
    
    # Load extensions.
    #
    load_relative 'extensions/object'
    load_relative 'extensions/array'
    load_relative 'extensions/symbol'
    load_relative 'extensions/module'
    load_relative 'extensions/hash'
    
    # Load harakiri.
    #
    load_relative 'rack/harakiri'
    
    # Requiring Helpers
    #
    load_relative 'helpers/measuring'
    
    # Character Substituters
    #
    load_relative 'character_substituters/west_european'
    
    # Calculations.
    #
    load_relative 'calculations/location'
    
    # Signal handling
    #
    load_relative 'signals'

    # Various.
    #
    load_relative 'loggers/search'

    # Index generation strategies.
    #
    load_relative 'indexers/no_source_specified_error'
    load_relative 'indexers/serial'
    #
    # load_relative 'indexers/solr'
    
    # Cacher.
    #
    load_relative 'cacher/strategy'
    
    # Partial index generation strategies.
    #
    load_relative 'cacher/partial/strategy'
    load_relative 'cacher/partial/none'
    load_relative 'cacher/partial/substring'
    load_relative 'cacher/partial/default'

    # Weight index generation strategies.
    #
    load_relative 'cacher/weights/strategy'
    load_relative 'cacher/weights/logarithmic'
    load_relative 'cacher/weights/default'
    
    # Similarity index generation strategies.
    #
    load_relative 'cacher/similarity/strategy'
    load_relative 'cacher/similarity/none'
    load_relative 'cacher/similarity/double_levenshtone'
    load_relative 'cacher/similarity/default'
    
    # Convenience accessors for generators.
    #
    load_relative 'cacher/convenience'
    
    # Index generators.
    #
    load_relative 'cacher/generator'
    load_relative 'cacher/partial_generator'
    load_relative 'cacher/weights_generator'
    load_relative 'cacher/similarity_generator'
    
    # Index store handling.
    #
    load_relative 'index/backend'
    
    load_relative 'index/redis'
    load_relative 'index/redis/basic'
    load_relative 'index/redis/list_hash'
    load_relative 'index/redis/string_hash'
    
    load_relative 'index/file/basic'
    load_relative 'index/file/text'
    load_relative 'index/file/marshal'
    load_relative 'index/file/json'
    
    load_relative 'index/files'
    
    # Indexing and Indexed things.
    #
    load_relative 'indexing/bundle/super_base' # TODO Remove.
    load_relative 'indexing/bundle/base'
    load_relative 'indexing/bundle/memory'
    load_relative 'indexing/bundle/redis'
    load_relative 'indexing/category'
    load_relative 'indexing/categories'
    load_relative 'indexing/index'
    load_relative 'indexing/indexes'
    
    load_relative 'indexed/bundle/base'
    load_relative 'indexed/bundle/memory'
    load_relative 'indexed/bundle/redis'
    load_relative 'indexed/category'
    load_relative 'indexed/categories'
    load_relative 'indexed/index'
    load_relative 'indexed/indexes'
    
    load_relative 'api/indexes'
    load_relative 'api/aliases'
    load_relative 'api/index/base'
    load_relative 'api/index/memory'
    load_relative 'api/index/redis'
    
    
    load_relative 'indexed/wrappers/exact_first'
    
    # Bundle Wrapper
    #
    load_relative 'indexed/wrappers/bundle/wrapper'
    load_relative 'indexed/wrappers/bundle/calculation'
    load_relative 'indexed/wrappers/bundle/location'
    
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
    load_relative 'query/combinations'
    
    load_relative 'query/allocation'
    load_relative 'query/allocations'
    
    load_relative 'query/qualifiers'
    
    load_relative 'query/indexes'
    
    load_relative 'query/weights'
    
    # Query.
    #
    load_relative 'query/base'
    load_relative 'query/live'
    load_relative 'query/full'
    #
    # load_relative 'query/solr'
    
    # Results.
    #
    load_relative 'results/base'
    load_relative 'results/full'
    load_relative 'results/live'
    
    # Sources.
    #
    load_relative 'sources/base'
    load_relative 'sources/db'
    load_relative 'sources/csv'
    load_relative 'sources/delicious'
    load_relative 'sources/couch'
    
    load_relative 'sources/wrappers/base'
    load_relative 'sources/wrappers/location'
    
    # Configuration.
    #
    load_relative 'configuration/index'
    
    # Interfaces
    #
    load_relative 'interfaces/live_parameters'
    
    # Adapters.
    #
    load_relative 'adapters/rack/base'
    load_relative 'adapters/rack/query'
    load_relative 'adapters/rack/live_parameters'
    load_relative 'adapters/rack'
    
    # Application and routing.
    #
    load_relative 'frontend_adapters/rack'
    load_relative 'application'
    
    # Load tools.
    #
    # load_relative 'solr/schema_generator'
    load_relative 'cores'
  end

end
