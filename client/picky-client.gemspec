require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'picky-client'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-client@gmail.com'

  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Picky Client'
  s.summary = 'picky Ruby Search Engine Client'

  s.has_rdoc = false

  s.files = Dir["lib/**/*.{rb,rake}", "javascripts/*.js"]

  s.test_files = Dir["spec/**/*_spec.rb"]
  s.extra_rdoc_files = ['README.rdoc']

  s.add_dependency('yajl-ruby', '>= 0.7.8')
end