module Picky
  
  # Picky class methods.
  #  * logger: Picky specific logger.
  #  * root: Root used for Picky (eg. index directories).
  #
  class << self
    attr_accessor :logger, :root
  end
  
  # Set default encoding.
  # (Note: Rails does this already as well)
  #
  # THINK Set default encoding?
  #
  # Encoding.default_external = Encoding::UTF_8
  # Encoding.default_internal = Encoding::UTF_8

  # External libraries.
  #
  require 'active_support/core_ext/module/delegation'
  require 'active_support/core_ext/logger'
  require 'active_support/core_ext/object/blank'
  require 'active_support/core_ext/enumerable'
  require 'active_support/multibyte'
  require 'multi_json'
  require 'procrastinate'
  require 'rack_fast_escape' if defined? Rack
  require 'fileutils'
  
  # Check if platform specific modifiers need to be installed.
  #
  
  # Note: We don't use require_relative yet because MacRuby
  # doesn't have it.
  #
  require File.expand_path '../picky/platforms/macruby', __FILE__
  
  # Modify/configure the external libraries.
  #
  
  # By default, MultiJson uses Yajl.
  #
  MultiJson.use :yajl if defined? ::Yajl
  
  # Require the constants.
  #
  require_relative 'picky/constants'
  
  # Set the root path of Picky.
  # (necessary for the index directory etc.)
  #
  Picky.root = Dir.pwd

  # Loader which handles framework and app loading.
  #
  require_relative 'picky/loader'

  # Load the framework
  #
  Loader.load_framework

  # Check if delegators need to be installed.
  #
  require_relative 'picky/sinatra'
  
  # Set the default logger.
  #
  # Options include:
  #  * Loggers::Silent
  #  * Loggers::Concise (default)
  #  * Loggers::Verbose
  #  
  self.logger = Loggers::Default

end