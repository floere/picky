begin
  require File.expand_path '../ruby19/performant', __FILE__
rescue LoadError
  require File.expand_path '../ruby19/extconf.rb', __FILE__
  Dir.chdir File.expand_path('../ruby19', __FILE__) do
    %x{ ruby extconf.rb && make }
  end
  retry
end