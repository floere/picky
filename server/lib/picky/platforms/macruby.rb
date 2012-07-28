# This tests if we are using MacRuby.
# If yes, it checks if we already have require_relative.
#
if RUBY_ENGINE == 'macruby' && !Kernel.respond_to?(:require_relative)
  
  module Kernel
    
    def require_relative relative_feature
      file = caller.first.split(/:\d/,2).first
      raise LoadError, "require_relative is called in #{$1}" if /\A\((.*)\)/ =~ file
      require File.expand_path relative_feature, File.dirname(file)
    end
    
  end
  
end