# Specs.
#
require 'rspec'
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new :rspec

task :simplecov do
  ENV['COV'] = 'yes'
end

desc "Run specs with coverage."
task :cov do
  Rake::Task['simplecov'].invoke
  Rake::Task['rspec'].invoke
end