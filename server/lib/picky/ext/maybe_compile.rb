begin
  require_relative 'ruby19/performant'
rescue LoadError
  require_relative 'ruby19/extconf'
  Dir.chdir File.expand_path('../ruby19', __FILE__) do
    %x{ ruby extconf.rb && make }
  end
  retry
end