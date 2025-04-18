require File.expand_path '../version', __dir__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.2'

  s.name = 'picky'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky@gmail.com'

  s.licenses = %w[MIT LGPL]

  s.homepage = 'http://florianhanke.com/picky'

  s.description = 'Fast Ruby semantic text search engine with comfortable single field interface.'
  s.summary = 'Picky: Semantic Search Engine. Clever Interface. Good Tools.'

  s.executables = ['picky']

  s.files = Dir["tools/**/*.rb", "lib/**/*.rb", "lib/tasks/*.rake", "ext/picky/picky.c"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.extensions << 'ext/picky/extconf.rb'

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'multi_json', '~> 1.3'
  # s.add_runtime_dependency 'google_hash', '~> 0.8'

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
  # s.add_runtime_dependency 'activerecord', '>= 3.0'
  # s.add_runtime_dependency 'redis'
  # s.add_runtime_dependency 'mysql'
  # s.add_runtime_dependency 'sqlite3'
  # s.add_runtime_dependency 'procrastinate', '~> 0.4'
end
