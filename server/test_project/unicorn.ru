listen            '0.0.0.0:8080'
pid               'tmp/pids/unicorn.pid'
preload_app       true
timeout           10
worker_processes  3

after_fork do |_, _|
  GC.disable
end