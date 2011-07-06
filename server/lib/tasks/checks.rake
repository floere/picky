# Checks to help the user.
#
desc 'Checks if index files are small/missing (index, category optional).'
task :check, [:index, :category] => :application do |_, options|
  index, category = options.index, options.category

  specific = Indexes
  specific = specific[index]    if index
  specific = specific[category] if category
  specific.check

  puts "All checked indexes look ok."
end