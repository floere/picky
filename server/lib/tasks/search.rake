# Tasks for testing your engine configuration in the terminal.
#
desc 'Simple terminal search - pass it an URL to search on, e.g. /books.'
task :search do
  puts <<-DEPRECATED
Deprecated. New usage:
  picky search <URL> [<result id amount = 20>]
  DEPRECATED
end