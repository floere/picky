module Picky

  # A very simple CLI selector.
  #
  class CLI # :nodoc:all

    # Execute a command.
    #
    # Note: By default, help is displayed. I.e. when no command is given.
    #
    def execute selector = nil, *args
      executor_class, *params = executor_class_for selector
      executor = executor_class.new
      executor.execute selector, args, params
    end
    def executor_class_for selector = nil
      selector && @@mapping[selector.to_sym] || [Help]
    end

    class Base
      def usage name, params
        puts "Usage:\n  picky #{name} #{params_to_s(params)}"
      end
      # String params are optional, Symbol params aren't.
      #
      def params_to_s params
        params.map { |param| param.respond_to?(:to_str) ? "[#{param}]" : param }.join(' ') if params
      end
    end
    class Generate < Base
      def execute name, args, params
        Kernel.system "picky-generate #{args.join(' ')}"
      end
    end
    class Help < Base
      # Displays usage information.
      #
      def execute name, args, params
        commands = Picky::CLI.mapping.map do |command, object_and_params|
          _, *params = object_and_params
          "  picky #{command} #{params_to_s(params)}"
        end.join(?\n)

        Kernel.puts "Possible commands:\n#{commands}\n"
      end
    end
    class Live < Base
      def execute name, args, params
        url  = args.shift
        port = args.shift

        usage(name, params) || exit(1) unless args.empty?

        ENV['PICKY_LIVE_URL']  = url
        ENV['PICKY_LIVE_PORT'] = port

        require 'picky-live'
        require 'picky-live/application/app'
      rescue LoadError => e
        require 'picky/extensions/object'
        warn_gem_missing 'picky-live', 'the Picky Live Interface'
        exit 1
      end
    end
    class Search < Base
      def execute name, args, params
        url_or_path = args.shift
        ids         = args.shift

        usage(name, params) || exit(1) unless url_or_path

        require 'picky-client'
        require 'picky-client/aux/terminal'
        terminal = Terminal.new url_or_path, ids
        terminal.run
      rescue LoadError => e
        require 'picky/extensions/object'
        warn_gem_missing 'picky-client', 'the Picky client'
        exit 1
      end
    end
    class Statistics < Base
      def execute name, args, params
        relative_log_file = args.shift
        port              = args.shift

        usage(name, params) || exit(1) unless relative_log_file

        ENV['PICKY_LOG_FILE']        = File.expand_path relative_log_file
        ENV['PICKY_STATISTICS_PORT'] = port

        require 'picky-statistics'
        require 'picky-statistics/application/app'
      rescue LoadError => e
        require 'picky/extensions/object'
        warn_gem_missing 'picky-statistics', 'the Picky statistics'
        exit 1
      end
    end

    # Maps commands to the other gem's command.
    #
    @@mapping = {
      :generate => [Generate, :'{sinatra_client,unicorn_server,empty_unicorn_server}', :'app_directory_name'],
      :help     => [Help],
      :live     => [Live, 'host:port/path (default: localhost:8080/admin)', 'port (default: 4568)'],
      :search   => [Search, :url_or_path, 'amount of ids (default 20)'],
      :stats    => [Statistics, :'logfile (e.g. log/search.log)', 'port (default: 4567)']
    }
    def self.mapping
      @@mapping
    end

  end

end