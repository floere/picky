module Picky

  # External libraries.
  #
  require 'active_support/core_ext/module/delegation'
  require 'active_support/core_ext/logger'
  require 'active_support/core_ext/object/blank'
  require 'active_support/core_ext/enumerable'
  require 'active_support/multibyte'
  require 'yajl'
  require 'procrastinate'
  require 'rack_fast_escape' if defined? Rack

  # Require the constants.
  #
  require_relative 'picky/constants'

  # Loader which handles framework and app loading.
  #
  require_relative 'picky/loader'

  # Load the framework
  #
  Loader.load_framework

  # Check if delegators need to be installed.
  #
  require_relative 'picky/sinatra'

  # This is only used in the classic project style.
  #
  class << self
    attr_accessor :logger
  end

end