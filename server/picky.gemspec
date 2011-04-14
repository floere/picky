require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'picky'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky@gmail.com'

  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Fast Ruby semantic text search engine with comfortable single field interface.'
  s.summary = 'Picky: Semantic Search Engine. Clever Interface. Good Tools.'

  s.executables = ['picky']
  s.default_executable = "picky"

  s.files = Dir["aux/**/*.rb", "lib/**/*.rb", "lib/tasks/*.rake", "lib/picky/internals/ext/ruby19/performant.c"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.extensions << 'lib/picky/internals/ext/ruby19/extconf.rb'

  s.add_development_dependency 'rspec'
end