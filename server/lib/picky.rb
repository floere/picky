module Picky

  # This is only used in the classic project style.
  #
  class << self
    attr_accessor :logger
  end

  # Require the constants.
  #
  require ::File.expand_path '../picky/constants', __FILE__

  # Library bundling.
  #
  require ::File.expand_path '../picky/bundling', __FILE__

  # Loader which handles framework and app loading.
  #
  require ::File.expand_path '../picky/loader', __FILE__

  # Load the framework
  #
  Loader.load_framework
  puts "Loaded picky with environment '#{PICKY_ENVIRONMENT}' in #{PICKY_ROOT} on Ruby #{RUBY_VERSION}."

  # Check if delegators need to be installed.
  #
  require ::File.expand_path '../picky/sinatra', __FILE__

end