# Server tasks, like starting/stopping/restarting.
#
desc "Start the server."
task :start do
  Rake::Task[:'server:start'].invoke
end
desc "Stop the server."
task :stop do
  Rake::Task[:'server:stop'].invoke
end

namespace :server do

  # desc "Start the unicorns. (Wehee!)"
  #
  task :start => :framework do
    chdir_to_root
    daemonize = PICKY_ENVIRONMENT == 'production' ? '-D' : ''
    ENV['PICKY_ENV'] = PICKY_ENVIRONMENT
    command = "unicorn -c unicorn.rb #{daemonize}".strip
    puts "Running \`#{command}\`."
    exec command
  end

  # desc "Stop the unicorns. (Blam!)"
  #
  task :stop => :framework do
    `kill -QUIT #{current_pid}` if current_pid
  end

  # desc "Restart the unicorns."
  task :restart do
    Rake::Task[:"server:stop"].invoke
    sleep 5
    Rake::Task[:"server:start"].invoke
  end

  def chdir_to_root
    Dir.chdir Picky.root
  end

  def current_pid
    pidfile = 'tmp/pids/unicorn.pid'
    pid = `cat #{File.join(Picky.root, pidfile)}`
    if pid.blank?
      puts
      puts "No server running (no #{pidfile} found)."
      puts
    else
      pid.chomp
    end
  end

end
