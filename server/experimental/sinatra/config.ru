require File.expand_path '../unicorn_app', __FILE__

# use Rack::ShowExceptions

run UnicornApp.new