failed = 0

begin
  require_relative 'ruby19/performant'
rescue LoadError
  failed += 1
  
  # For some reason we need to enter ./ruby19
  # via external command (see issue #81).
  #
  Dir.chdir File.expand_path('..', __FILE__) do
    puts %x(cd ruby19; ruby extconf.rb; make)
  end
  
  # Try again.
  #
  retry if failed < 2
  
  # Give up and inform the user.
  #
  puts <<-NOTE

Picky tried to compile its source on your system but failed.
Please add an issue: https://github.com/floere/picky/issues/
and copy anything into it that you think is helpful. Thanks!

See related issue: https://github.com/floere/picky/issues/81

NOTE
  exit 1
end