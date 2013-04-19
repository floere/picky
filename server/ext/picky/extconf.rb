# Information.
#
puts
print "Compiling on Ruby #{RUBY_VERSION}"
if defined?(RbConfig)
  RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC'] 
  print " with CC set to #{RbConfig::MAKEFILE_CONFIG['CC']}"
end
puts "."

# Compile.
#
require 'mkmf'
abort 'need ruby.h' unless have_header("ruby.h")
create_makefile 'picky/picky'
puts