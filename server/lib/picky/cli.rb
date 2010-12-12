module Picky
  
  # A very simple CLI selector.
  #
  class CLI # :nodoc:all
    
    def self.mapping
      @@mapping
    end
    
    # Execute a command.
    #
    # Note: By default, help is displayed. I.e. when no command is given.
    #
    def execute selector = nil, *args
      executor_class, *params = selector && @@mapping[selector.to_sym] || Help
      executor = executor_class.new
      executor.execute selector, args, params
    end
    
    class Base
      def usage name, params
        puts "Usage\n  picky #{name} #{params_to_s(params)}"
      end
      def params_to_s params
        params.map { |param| "<#{param}>" }.join(' ') if params
      end
    end
    class Generate < Base
      def execute name, args, params
        system "picky-generate #{args.join(' ')}"
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
        
        puts "Possible commands:\n" + commands
      end
    end
    
    # Maps commands to the other gem's command.
    #
    # TODO Add optional params.
    #
    @@mapping = {
      :generate => [Generate, 'thing_to_generate: e.g. "unicorn_server"', :parameters],
      :help     => [Help]
    }
    
  end
  
end