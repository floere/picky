# Tasks for testing your engine configuration in the terminal.
#
task :search do
  load File.expand_path '../../picky/auxiliary/terminal.rb', __FILE__
  terminal = Terminal.new ARGV[1] || raise("Usage:\n  rake search <URL>\n  E.g. rake search /books\n       rake search localhost:8080/books")
  terminal.run
end