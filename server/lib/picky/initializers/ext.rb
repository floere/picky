# TODO Move to ext. Call possibly_compile.rb.
#
begin
  require File.expand_path '../../ext/ruby19/performant', __FILE__
rescue LoadError
  require File.expand_path '../../ext/ruby19/extconf.rb', __FILE__
  Dir.chdir File.expand_path('../../ext/ruby19', __FILE__) do
    %x{ ruby extconf.rb && make }
  end
  retry
end