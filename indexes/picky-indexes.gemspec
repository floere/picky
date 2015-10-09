require File.expand_path '../../version', __FILE__

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  
  s.name = 'picky-client'
  s.version = Picky::VERSION

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-indexes@gmail.com'

  s.licenses = ['MIT']

  s.homepage = 'http://pickyrb.com'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'

  s.description = 'Picky Indexes'
  s.summary = 'A collection for indexes for the Picky Ruby Search Engine.'

  s.has_rdoc = false

  s.files = Dir["lib/**/*.{rb,rake}"]

  s.test_files = Dir["spec/**/*_spec.rb"]
  # s.extra_rdoc_files = ['README.rdoc']
end
