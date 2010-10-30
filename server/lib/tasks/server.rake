# TODO This file needs some love.
#
namespace :server do
  
  def chdir_to_root
    Dir.chdir PICKY_ROOT
  end
  
  def current_pid
    pid = `cat #{File.join(PICKY_ROOT, 'tmp/pids/unicorn.pid')}`
    pid.blank? ? nil : pid.chomp
  end
  
  # desc "Start the unicorns. (Wehee!)"
  task :start => :framework do
    chdir_to_root
    # Rake::Task[:"solr:start"].invoke # TODO Move to better place.
    daemonize = PICKY_ENVIRONMENT == 'production' ? '-D' : ''
    command = "export PICKY_ENV=#{PICKY_ENVIRONMENT}; unicorn -c unicorn.ru #{daemonize}".strip
    puts "Running \`#{command}\`."
    exec command
  end
  
  # desc "Stop the unicorns. (Blam!)"
  task :stop => :framework do
    `kill -QUIT #{current_pid}` if current_pid
    # Rake::Task[:"solr:stop"].invoke # TODO Move to better place.
  end
  
  # desc "Restart the unicorns."
  task :restart do
    Rake::Task[:"server:stop"].invoke
    sleep 5
    Rake::Task[:"server:start"].invoke
  end
  
end
