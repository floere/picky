worker_processes 2
listen           '/tmp/unicorn.sock', :backlog => 1
listen           9292, :tcp_nopush => true
timeout          10
pid              'tmp/pids/unicorn.pid'
preload_app      true

after_fork do |_, _|
  GC.disable
end