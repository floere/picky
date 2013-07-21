require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'picky-live'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-live@gmail.com'
  
  s.licenses = ['MIT', 'LGPL']

  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Live parameters interface for Picky, the fast Ruby search engine.'
  s.summary = 'Displays parameters (and the possibility of updating them) for Picky.'

  s.files = Dir["lib/**/*"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.add_dependency 'sinatra', '~> 1.0'

  s.add_development_dependency 'rspec', '>= 1.3.0'
  s.add_development_dependency 'activesupport', '>= 3.0'
end