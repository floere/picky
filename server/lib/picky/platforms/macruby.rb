# This tests if we are using MacRuby.
# If yes, it checks if we already have require_relative.
#
# TODO Remove (too verbose) message as soon as it is final.
#
if RUBY_ENGINE == 'macruby' && !Kernel.respond_to?(:require_relative)
  
  puts "Installing Picky specific MacRuby extensions."
  
  # Note by @overbryd in https://gist.github.com/1710233:
  # require fileutils to use FileUtils. Otherwise an error gets raised.
  # uninitialized constant Picky::Backends::Helpers::File::FileUtils (NameError)
  #
  require 'fileutils'
  
  module Kernel
    
    def require_relative relative_feature
      file = caller.first.split(/:\d/,2).first
      raise LoadError, "require_relative is called in #{$1}" if /\A\((.*)\)/ =~ file
      require File.expand_path relative_feature, File.dirname(file)
    end
    
  end
  
end