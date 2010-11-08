Gem::Specification.new do |s|
  s.name = 'picky-client'
  s.version = '0.11.0'
  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky-client@gmail.com'
  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'
  s.description = 'Fast Combinatorial Ruby Search Engine Client'
  s.platform = Gem::Platform::RUBY
  s.summary = 'picky Search Engine Client'
  s.executables = ['picky-client']
  s.default_executable = "picky-client"
  s.files = Dir["lib/**/*.rb", "sinatra_prototype/**/*"]
  s.test_files = Dir["spec/**/*_spec.rb"]
  s.has_rdoc = false
  s.extra_rdoc_files = ['README.rdoc']
  
  s.add_dependency('yajl-ruby', '>= 0.7.8')
end