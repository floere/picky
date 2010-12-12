module Picky
  
  module Generators

    # Selects the right generator.
    #
    class Selector
  
      attr_reader :types

      def initialize
        @types = {
          :sinatra_client => [Client::Sinatra, :sinatra_project_name],
          :unicorn_server => [Server::Unicorn, :unicorn_project_name]
        }
      end

      # Run the generators with this command.
      #
      # This will "route" the commands to the right specific generator.
      #
      def generate args
        generator = generator_for *args
        generator.generate
      end

      #
      #
      def generator_for identifier, *args
        generator_info = types[identifier.to_sym]
        raise NotFoundException.new(self) unless generator_info
        generator_class = generator_info.first
        generator_for_class generator_class, identifier, *args
      end

      #
      #
      def generator_for_class klass, *args
        klass.new *args
      end
    end
    
  end
  
end