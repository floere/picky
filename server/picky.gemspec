Gem::Specification.new do |s|
  s.name = 'picky'
  s.version = '0.10.0'
  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+picky@gmail.com'
  s.homepage = 'http://floere.github.com/picky'
  s.rubyforge_project = 'http://rubyforge.org/projects/picky'
  s.description = 'Fast Combinatorial Ruby Search Engine'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Picky the Search Engine'
  s.executables = ['picky']
  s.default_executable = "picky"
  s.files = Dir["lib/**/*.rb", "lib/tasks/*.rake", "lib/picky/ext/ruby19/performant.c", "project_prototype/**/*"]
  s.test_files = Dir["spec/**/*_spec.rb"]
  
  s.extensions << 'lib/picky/ext/ruby19/extconf.rb'
  
  s.add_development_dependency 'rspec'
end