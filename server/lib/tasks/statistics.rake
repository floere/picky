namespace :statistics do

  desc "start the server"
  task :start => :application do
    Statistics.start unless SEARCH_ENVIRONMENT == 'test'
  end
  
  desc "stop the server"
  task :stop => :application do
    Statistics.stop unless SEARCH_ENVIRONMENT == 'test'
  end
  
end