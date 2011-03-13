# Statistics tasks.
#
namespace :stats do
  task :prepare => :application do
    require File.expand_path('../../picky/statistics', __FILE__)
    statistics = Statistics.instance
  end
  task :app => :prepare do
    Statistics.instance.application
    puts Statistics.instance
  end
  task :analyze => :prepare do
    begin
      Statistics.instance.analyze
    rescue StandardError
      puts "\n\033[31mNote: rake analyze needs prepared indexes. Run rake index first.\033[m\n\n"
      raise
    end
    puts Statistics.instance
  end
end