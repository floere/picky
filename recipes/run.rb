Person = Struct.new :id, :first, :last

Dir['**/*.rb'].each { |file| require File.expand_path "../#{file}", __FILE__ }