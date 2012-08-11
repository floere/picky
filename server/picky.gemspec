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

  s.files = Dir["aux/**/*.rb", "lib/**/*.rb", "lib/tasks/*.rake", "lib/performant.c"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.extensions << 'lib/extconf.rb'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'picky-client', "~> #{Picky::VERSION}"

  s.add_runtime_dependency 'text'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'activesupport', '~> 3'
  s.add_runtime_dependency 'procrastinate', '~> 0.4'
  s.add_runtime_dependency 'rack_fast_escape'

  # Optional dependencies.
  #
  # Note: Commented to make installing Picky
  #       less error prone. Picky will tell the
  #       users to install the gems if they need it.
  #
  # s.add_runtime_dependency 'unicorn'
  # s.add_runtime_dependency 'sinatra'
  # s.add_runtime_dependency 'rack'
  # s.add_runtime_dependency 'yajl-ruby' # As JSON lib we suggest to use yajl.
  # s.add_runtime_dependency 'activerecord', '~> 3'
  # s.add_runtime_dependency 'redis'
  # s.add_runtime_dependency 'mysql'
  # s.add_runtime_dependency 'sqlite3'
end
