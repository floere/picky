begin
  require ::File.expand_path '../picky/picky', __FILE__
rescue LoadError => e
  # Give up and inform the user.
  #
  puts <<-NOTE

Picky tried to compile its source on your system but failed.

If you are trying to develop for it, please run the specs first:
bundle exec rake
(You might need to set ulimit -n 3000 for the tests to run)

Please add an issue: https://github.com/floere/picky/issues/
and copy anything into it that you think is helpful. Thanks!

See related issue: https://github.com/floere/picky/issues/81

The problem reported by the compiler was:
#{e}

NOTE
  exit 1
end