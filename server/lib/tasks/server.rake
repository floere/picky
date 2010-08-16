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
    Rake::Task[:"solr:start"].invoke # TODO Move to better place.
    config = {}
    config['production'] = {
      :port      => 6000,
      :daemonize => true
    }
    config['development'] = {
      :port      => 4000,
      :daemonize => false
    }
    port = SEARCH_ENVIRONMENT == 'production' ? 6000 : 4000
    `export SEARCH_ENV=#{SEARCH_ENVIRONMENT}; unicorn -p #{config[SEARCH_ENVIRONMENT][:port]} -c #{File.join(SEARCH_ROOT, 'config/unicorn.ru')} #{config[SEARCH_ENVIRONMENT][:daemonize] ? '-D' : ''} #{File.join(SEARCH_ROOT, 'app/application.ru')}`
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
    Rake::Task[:"solr:stop"].invoke # TODO Move to better place.
  end

  # TODO
  #
  desc 'send the USR1 signal to the thin server'
  task :usr1 => :ruby_version do
    puts "Sending USR1 signal to the thin server."
    `pidof thin#{RUBY_VERSION_APPENDIX}`.split.each { |pid| Process.kill('USR1', pid.to_i) }
  end
end
