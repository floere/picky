# This tests if we are using MacRuby.
# If yes, it checks if we already have require_relative.
#
# TODO Remove (too verbose) message as soon as it is final.
#
if Kernel.respond_to?(:to_plist) && !Kernel.respond_to?(:require_relative)
  
  puts "Installing Picky specific MacRuby extensions."
  
  module Kernel
    
    def require_relative relative_feature
      file = caller.first.split(/:\d/,2).first
      raise LoadError, "require_relative is called in #{$1}" if /\A\((.*)\)/ =~ file
      require File.expand_path relative_feature, File.dirname(file)
    end
    
  end
  
end