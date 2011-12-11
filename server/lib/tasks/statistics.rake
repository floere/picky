# Statistics tasks.
#
desc "Analyzes indexes (index, category optional)."
task :analyze, [:index, :category] => :'stats:prepare' do |_, options|
  index, category = options.index, options.category

  specific = Picky::Indexes
  specific = specific[index]    if index
  specific = specific[category] if category

  statistics = Picky::Statistics.new

  begin
    statistics.analyze specific
  rescue StandardError
    puts "\n\033[31mNote: rake analyze needs prepared indexes. Run rake index first.\033[m\n\n"
    raise
  end

  puts statistics
end

task :stats => :'stats:prepare' do
  stats = Picky::Statistics.new
  puts stats.application
end

namespace :stats do

  task :prepare => :application do
    require_relative '../picky/statistics'
  end

end