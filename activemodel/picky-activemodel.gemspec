require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'picky-activemodel'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-activemodel@gmail.com'

  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Picky ActiveModel Integration'
  s.summary = 'Makes it possible to index and search Picky from your ActiveModels'

  s.has_rdoc = false

  s.files = Dir["lib/**/*.{rb,rake}"]

  # s.test_files = Dir["spec/**/*_spec.rb"]
  s.extra_rdoc_files = ['README.rdoc']

  s.add_dependency 'activemodel', '~> 3.0'
end
