# sunspot-solr start --solr-home=solr --data-directory=index/development/solr --pid-dir=solr/pids --log-file=log/solr.log

namespace :solr do
  
  namespace :schema do
    task :generate => :application do
      generator = Solr::SchemaGenerator.new Indexes.configuration
      generator.generate
    end
  end
  
  
  task :index => :application do
    Rake::Task[:"solr:start"].invoke
    sleep 3
    Indexes.index_solr
  end
  
  
  def action name
    `sunspot-solr #{name} --solr-home=solr --data-directory=index/#{PICKY_ENVIRONMENT}/solr --pid-dir=solr/pids --log-file=log/solr.log`
  end
  task :start => :application do
    Rake::Task['solr:schema:generate'].invoke
    action :start
  end
  task :stop => :application do
    action :stop
  end
  task :restart => :application do
    action :stop
    sleep 2
    action :start
  end
  
end