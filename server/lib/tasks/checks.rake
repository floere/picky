# Checks to help the user.
#
namespace :check do

  desc 'Checks the index files for files that are suspiciously small or missing.'
  task :index => :application do
    Indexes.check_caches
    puts "All indexes look ok."
  end

end