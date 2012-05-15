require File.expand_path '../constants', __FILE__

module Picky
  module Capistrano

    # Include all
    #
    module All
      def self.extended cap_config

        cap_config.instance_eval do

          # Executes a rake task on the server.
          #
          # Options:
          #  * env: The PICKY_ENV. Will not set if set explicitly to false. Default: production.
          #  * All other options get passed on to the Capistrano run task.
          #
          def execute_rake_task name, options = {}, &block
            env = options.delete :env
            env = env == false ? '' : "PICKY_ENV=#{env || 'production'}"
            run "cd #{current_path}; rake #{name} #{env}", options, &block
          end

        end

        cap_config.extend Standard
        cap_config.extend Deploy
        cap_config.extend Caching
        cap_config.extend Overrides

      end
    end

    # Removes unneeded Rails defaults.
    #
    module Overrides
      def self.extended cap_config
        cap_config.instance_eval do

          namespace :deploy do
            tasks.delete :check
            tasks.delete :cold
            tasks.delete :migrations
            tasks.delete :migrate
            tasks.delete :upload

            namespace :web do
              tasks.delete :enable
              tasks.delete :disable
            end
          end

        end
      end
    end

    module Standard
      def self.extended cap_config
        cap_config.load 'standard'
        cap_config.load 'deploy'
      end
    end

    module Deploy

      def self.extended cap_config
        cap_config.instance_eval do

          namespace :deploy do
            %w(start stop).each do |action|
              desc "#{action} the Servers"
              task action.intern, :roles => :app do
                execute_rake_task "server:#{action}"
              end
            end
            desc "Restart the Servers sequentially"
            task :restart, :roles => :app do
              find_servers(:roles => :app).each do |server|
                execute_rake_task "server:restart", :hosts => server.host
              end
            end

            desc 'Hot deploy the code'
            task 'hot', :roles => :app do
              update
              execute_rake_task 'server:usr1', :env => false # No env needed.
            end

            desc "Setup a GitHub-style deployment."
            task :setup, :roles => :app do
              cmd = "git clone #{repository} #{current_path}-clone-cache &&" +
                    "rm #{current_path} &&" +
                    "mv #{current_path}-clone-cache #{current_path}"
              run cmd
            end

            desc "Deploy"
            task :default, :roles => :app do
              update
              restart
            end

            desc "Update the deployed code."
            task :update_code do # code needs to be updated with all servers
              puts "updating code to branch #{branch}"
              cmd = "cd #{current_path} &&" +
                    "git fetch origin &&" +
                    "(git checkout -f #{branch} || git checkout -b #{branch} origin/#{branch}) &&" +
                    "git pull;" +
                    "git branch"
              run cmd
              symlink
            end

            desc "Cleans up the git checkout"
            task :cleanup, :roles => :app do
              run "cd #{current_path} && git gc --aggressive"
            end

            desc "create the symlinks to the shared dirs"
            task :symlink do
              set :user, 'deploy'
              run "rm -rf #{current_path}/log;   ln -sf #{shared_path}/log   #{current_path}/log"
              run "rm -rf #{current_path}/index; ln -sf #{shared_path}/index #{current_path}/index"
              # link database-config files
              run "ln -sf #{shared_path}/app/db.yml #{current_path}/app/db.yml"
              # link unicorn.ru
              run "ln -sf #{shared_path}/unicorn.ru #{current_path}/unicorn.ru"
            end

            namespace :rollback do
              desc "Rollback to last release."
              task :default, :roles => :app do
                set :branch, branches[-2]
                puts "rolling back to branch #{branch}"
                deploy.update_code
              end

              task :code, :roles => :app do
                # implicit
              end
            end
          end

        end
      end

    end

    module Caching

      def self.extended cap_config
        cap_config.instance_eval do
          namespace :cache do
            desc "check the index files if they are ready to be used"
            task :check, :roles => :cache do
              execute_rake_task 'cache:check'
            end
          end
          namespace :cache do
            namespace :structure do
              desc "create the index cache structure"
              task :create, :roles => :app do
                execute_rake_task 'cache:structure:create'
              end
            end
          end
          namespace :solr do
            desc "create the index cache structure"
            task :index, :roles => :cache do
              execute_rake_task 'solr:index'
            end
            %w|start stop restart|.collect(&:to_sym).each do |action|
              desc "#{action} the solr server"
              task action, :roles => :app do
                execute_rake_task 'solr:start'
              end
            end
          end
        end
      end

    end

    module Statistics

      def self.extended cap_config
        namespace :statistics do
          desc 'Start the statistics server'
          task :start, :roles => :statistics do
            set :user, 'root'
            run "daemonize -c #{current_path} -u deploy -v #{current_path}/script/statistics/start production"
          end
          desc 'Stop the statistics server'
          task :stop, :roles => :statistics do
            run "#{current_path}/script/statistics/stop production"
          end
          desc 'Restart the statistics server'
          task :restart, :roles => :statistics do
            stop
            sleep 2
            start
          end
        end
      end

    end

  end
end