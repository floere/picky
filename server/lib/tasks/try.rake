# Tasks for manually testing your engine configuration.
#
desc 'Try the given text in the indexer/query (index and category optional).'
task :try, %i[text index category] => :application do |_, options|
  puts
  unless options.text
    raise "\x1b[31mrake try needs a text to try indexing and query preparation\x1b[m, e.g. rake 'try[yourtext]'."
  end

  require_relative 'try'
  try = Picky::Try.new options.text, options.index, options.category
  try.to_stdout
end
