# Run with:
#   ruby stackprof.rb
#
require 'stackprof'
require 'sinatra/base'
require_relative '../lib/picky'
require_relative '../../client/lib/picky-client'
require_relative '../../client/lib/picky-client/spec'

data = Picky::Index.new :some_index do
  category :name
  category :surname
end

1000.times do |i|
  data.replace_from id: i, name: 'florian', surname: 'hanke'
end

people = Picky::Search.new data

# This is the application that is tested.
#
PerformanceServer = Class.new(Sinatra::Base) do
  set :protection, false
  
  use StackProf::Middleware, enabled: true, mode: :cpu

  get '/test' do
    results = people.search params[:query], params[:ids] || 20, params[:offset] || 0
    results.to_json
  end
end

client = Picky::TestClient.new PerformanceServer, :path => '/test'

%w|cpu object|.each do |thing|
  profile = StackProf.run(mode: thing.to_sym) do
    10000.times { client.search 'florian' }
  end
  path = "/tmp/stackprof-#{thing}-picky.dump"
  File.open(path, 'wb'){ |f| f.write Marshal.dump(profile) }
  puts `stackprof #{path}`
end
%w|cpu object|.each do |thing|
  profile = StackProf.run(mode: thing.to_sym) do
    10000.times { people.search 'florian' }
  end
  path = "/tmp/stackprof-#{thing}-picky.dump"
  File.open(path, 'wb'){ |f| f.write Marshal.dump(profile) }
  puts `stackprof #{path}`
end