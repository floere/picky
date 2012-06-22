RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC'] 

puts "Compiling on Ruby 1.9 with CC set to #{RbConfig::MAKEFILE_CONFIG['CC']}."
require 'mkmf'

abort 'need ruby.h' unless have_header("ruby.h")

dir_config('performant')
create_makefile('performant')