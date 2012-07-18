Dir.chdir File.expand_path('..', __FILE__) do
  # Information.
  #
  print "Compiling on Ruby 1.9"
  if defined?(RbConfig)
    RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC'] 
    print " with CC set to #{RbConfig::MAKEFILE_CONFIG['CC']}"
  end
  puts " into #{Dir.pwd}."

  # Compile.
  #
  require 'mkmf'

  abort 'need ruby.h' unless have_header("ruby.h")
  
  create_makefile('picky/ext/ruby19/performant')
end