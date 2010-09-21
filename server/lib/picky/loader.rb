# Loads the search engine and itself.
#
module Loader
  
  # Reloads the whole app.
  # First itself, then the app.
  #
  def self.reload
    Dir.chdir(SEARCH_ROOT)
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
    load File.join(SEARCH_ROOT, "#{filename}.rb")
  end
  def self.load_user_lib filename
    load_user File.join('lib', filename)
  end
  def self.load_all_user_in dirname
    Dir[File.join(SEARCH_ROOT, dirname, '**', '*.rb')].each do |filename|
      load filename
    end
  end
  
  # def self.add_lib_dir
  #   lib_dir = File.join(SEARCH_ROOT, 'lib')
  #   $:.unshift lib_dir unless $:.include?(lib_dir)
  # end
  
  # Load the user's application.
  #
  def self.load_application
    # DB::Source.connect # FIXME only needed when indexing.
    # Load the user's application.
    #
    exclaim 'Loading app configuration.'
    
    load_all_user_in 'app/initializers'
    
    # Add lib dir to load path.
    #
    # add_lib_dir
    
    # Picky autoloading.
    #
    begin
      load_all_user_in 'lib/tokenizers'
      load_all_user_in 'lib/indexers'
      load_all_user_in 'lib/query'
    rescue NameError => name_error
      namespaced_class_name = name_error.message.gsub /^uninitialized\sconstant\s/, ''
      load_user_lib namespaced_class_name.underscore # Try it once.
      retry
    end
    
    # TODO Rethink this.
    #
    load_user 'app/logging'
    # load_user 'app/config'
    # Configuration.apply
    
    # Require the user's application.
    #
    load_user 'app/application'
    
    # Setup Indexes from user definition
    #
    # TODO Make special task that reloads the indexes!
    #
    Query::Qualifiers.instance.prepare # TODO Rewrite
    
    exclaim "Application loaded."
  end
  
  # Loads the framework.
  #
  def self.load_framework
    # exclaim 'Loading the application.'
    
    # exclaim 'Compiling C code.'
    require_relative 'initializers/ext'
    
    require 'rack_fast_escape'
    # exclaim 'Loaded rack_fast_escape.'
    require 'text'
    # exclaim 'Loaded text.'
    
    # Extend path with lib
    #
    extend_load_path 'lib'
    
    # Load extensions.
    #
    load_relative 'extensions/array'
    load_relative 'extensions/symbol'
    load_relative 'extensions/module'
    load_relative 'extensions/hash'
    # exclaim "Loaded extensions."
    
    # Load harakiri.
    #
    load_relative 'rack/harakiri'
    
    # Requiring Helpers
    #
    load_relative 'helpers/gc'
    load_relative 'helpers/cache'
    load_relative 'helpers/measuring'
    load_relative 'helpers/search'
    # exclaim "Loaded helpers."
    
    # Signal handling
    #
    load_relative 'signals'
    # exclaim "Loaded signals handling."

    # Load and require the plugins.
    #
    Dir['plugins/*'].each do |directory|
      extend_load_path directory
      extend_load_path directory, 'lib'
      load "#{directory.gsub!(/plugins\//, '')}.rb"
    end
    # exclaim "Loaded plugins."

    # Require the necessary libs. Referenced modules first.
    #
    load_relative 'loggers/search'
    load_relative 'umlaut_substituter'

    # Index generation strategies.
    #
    load_relative 'indexers/base'
    load_relative 'indexers/field'
    load_relative 'indexers/default'
    #
    load_relative 'indexers/solr'

    # Partial index generation strategies.
    #
    load_relative 'cacher/partial/strategy'
    load_relative 'cacher/partial/none'
    load_relative 'cacher/partial/subtoken'
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
    # TODO Just remove from under Cacher?
    #
    load_relative 'cacher/convenience'
    
    # Index generators.
    #
    load_relative 'cacher/generator'
    load_relative 'cacher/partial_generator'
    load_relative 'cacher/weights_generator'
    load_relative 'cacher/similarity_generator'
    
    # Index types.
    #
    load_relative 'index/bundle'
    load_relative 'index/category'
    load_relative 'index/type'
    
    load_relative 'index/combined'
    
    # Tokens.
    #
    load_relative 'query/token'
    load_relative 'query/tokens'
    
    # Tokenizers types.
    #
    load_relative 'tokenizers/base'
    load_relative 'tokenizers/index'
    load_relative 'tokenizers/query'
    load_relative 'tokenizers/default'
    
    # Query combinations, qualifiers, weigher.
    #
    load_relative 'query/combination'
    load_relative 'query/combinations'

    load_relative 'query/allocation'
    load_relative 'query/allocations'

    load_relative 'query/qualifiers'
    load_relative 'query/weigher'
    load_relative 'query/combinator'

    load_relative 'query/heuristics'

    # Query.
    #
    load_relative 'query/base'
    load_relative 'query/live'
    load_relative 'query/full'
    load_relative 'query/solr' # TODO ?

    # Results.
    #
    load_relative 'results/base'
    load_relative 'results/full'
    load_relative 'results/live'
    
    # Sources.
    #
    load_relative 'sources/base'
    load_relative 'sources/db'
    
    # DB
    #
    load_relative 'database/source'
    
    # Indexes.
    #
    load_relative 'indexes'
    
    # Configuration.
    #
    load_relative 'configuration/field'
    load_relative 'configuration/type'
    load_relative 'configuration/indexes'
    load_relative 'configuration/configuration'
    
    # ... in Application.
    #
    load_relative 'configuration/queries'
    
    # Application and routing.
    #
    load_relative 'routing'
    load_relative 'application'
    
    # Load tools.
    #
    load_relative 'solr/schema_generator'
    load_relative 'cores'
    
    # Load generation.
    #
    load_relative 'generator'
  end

  def self.exclaim text
    puts text
  end

  def self.extend_load_path *dirs
    dir = File.join(SEARCH_ROOT, *dirs)
    $:.unshift dir unless $:.include? dir
  end

end