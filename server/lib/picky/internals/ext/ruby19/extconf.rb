puts 'Compiling with Ruby 1.9'
require 'mkmf'

abort 'need ruby.h' unless have_header("ruby.h")

dir_config('performant')
create_makefile('performant')