require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'picky'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky@gmail.com'

  s.homepage = 'http://florianhanke.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Fast Ruby semantic text search engine with comfortable single field interface.'
  s.summary = 'Picky: Semantic Search Engine. Clever Interface. Good Tools.'

  s.executables = ['picky']
  s.default_executable = "picky"

  s.files = Dir["aux/**/*.rb", "lib/**/*.rb", "lib/tasks/*.rake", "lib/picky/ext/ruby19/performant.c"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.extensions << 'lib/picky/ext/ruby19/extconf.rb'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'picky-client', "~> #{Picky::VERSION}"

  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'rack_fast_escape'
  s.add_runtime_dependency 'text'
  s.add_runtime_dependency 'yajl-ruby'
  s.add_runtime_dependency 'activesupport', '~> 3.0'
  s.add_runtime_dependency 'activerecord', '~> 3.0'

  # Optional dependencies, but they still need to be here.
  #
  s.add_runtime_dependency 'unicorn'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'redis'
  s.add_runtime_dependency 'mysql'
  s.add_runtime_dependency 'sqlite3'
end
