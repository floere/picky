require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  
  s.name = 'picky-client'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-client@gmail.com'

  s.licenses = ['MIT', 'LGPL']

  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Picky Client'
  s.summary = 'Picky Ruby Search Engine Client'

  s.has_rdoc = false

  s.files = Dir["lib/**/*.{rb,rake}", "javascripts/*.js"]

  s.test_files = Dir["spec/**/*_spec.rb"]
  s.extra_rdoc_files = ['README.rdoc']

  s.add_runtime_dependency 'yajl-ruby' # We suggest to use Yajl.
  s.add_runtime_dependency 'activesupport', '~> 3.0'
end
