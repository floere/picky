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

  # Load Rack fast escape if Rack is used.
  #
  require 'rack_fast_escape' if defined? Rack

  # Require the constants.
  #
  require ::File.expand_path '../picky/constants', __FILE__

  # Loader which handles framework and app loading.
  #
  require ::File.expand_path '../picky/loader', __FILE__

  # Load the framework
  #
  Loader.load_framework

  # Check if delegators need to be installed.
  #
  require ::File.expand_path '../picky/sinatra', __FILE__

  # This is only used in the classic project style.
  #
  class << self
    attr_accessor :logger
  end

end