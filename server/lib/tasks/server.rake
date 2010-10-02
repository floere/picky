# TODO This file needs some love.
#
namespace :server do
  def chdir_to_root
    Dir.chdir SEARCH_ROOT
  end
  def current_pid
    pid = `cat #{File.join(SEARCH_ROOT, 'tmp/pids/unicorn.pid')}`
    pid.blank? ? nil : pid.chomp
  end
  desc "Start the unicorns. Weheee!"
  task :start => :application do
    chdir_to_root
    # Rake::Task[:"solr:start"].invoke # TODO Move to better place.
    config = {}
    config['production'] = {
      :daemonize => true
    }
    config['development'] = {
      :daemonize => false
    }
    puts `export SEARCH_ENV=#{SEARCH_ENVIRONMENT}; unicorn -c #{File.join(SEARCH_ROOT, 'unicorn.ru')} #{config[SEARCH_ENVIRONMENT][:daemonize] ? '-D' : ''}`
  end
  desc "Restart the unicorns!"
  task :restart do
    Rake::Task[:"server:stop"].invoke
    sleep 15
    Rake::Task[:"server:start"].invoke
  end
  desc "Stop the unicorns. Blam!"
  task :stop => :application do
    chdir_to_root
    `kill -QUIT #{current_pid}` if current_pid
    # Rake::Task[:"solr:stop"].invoke # TODO Move to better place.
  end
end
