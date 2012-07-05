# Information.
#
print "Compiling on Ruby 1.9"
if defined?(RbConfig)
  RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC'] 
  print " with CC set to #{RbConfig::MAKEFILE_CONFIG['CC']}"
end
puts "."

# Compile.
#
require 'mkmf'

abort 'need ruby.h' unless have_header("ruby.h")

dir_config('performant')
create_makefile('performant')