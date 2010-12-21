require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  
  s.name = 'picky-statistics'
  s.version = Picky::VERSION
  
  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-statistics@gmail.com'
  
  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'
  
  s.description = 'Statistics interface for Picky, the fast Ruby search engine.'
  s.summary = 'Displays search statistics for Picky.'
  
  s.files = Dir["lib/**/*"]
  s.test_files = Dir["spec/**/*_spec.rb"]
  
  s.add_dependency 'sinatra', '~> 1.0'
  
  s.add_development_dependency 'rspec', '>= 1.3.0'
end