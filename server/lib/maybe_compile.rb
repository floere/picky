# Note: This is handled toplevel to not confuse compilers.
#
failed = 0

begin
  require File.expand_path '../performant', __FILE__
rescue LoadError => e
  failed += 1
  
  # Have Makefile built.
  #
  require File.expand_path '../extconf', __FILE__
  
  # Run make.
  #
  puts %x(make)
  
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

The problem reported by the compiler was:
#{e}

NOTE
  exit 1
end