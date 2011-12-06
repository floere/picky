module Picky

  # External libraries.
  #
  require 'active_support/core_ext'
  require 'text'
  require 'yajl' # THINK Maybe replace by multi_json?
  require 'rack' # TODO Remove.
  require 'rack_fast_escape' # TODO Remove.
  require 'procrastinate'

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