module Picky

  module Generators

    # Selects the right generator.
    #
    class Selector

      attr_reader :types

      # TODO All-in-one-server.
      #
      def initialize
        @types = {
          :sinatra_client       => [Client::Sinatra, :sinatra_client_name],
          :client               => [Client::Sinatra, :client_name]

          :unicorn_server       => [Server::Unicorn, :unicorn_server_name],
          :empty_unicorn_server => [Server::EmptyUnicorn, :empty_unicorn_server_name],
          :sinatra_server       => [Server::Sinatra, :sinatra_server_name],
          :server               => [Server::Sinatra, :server_name]
        }
      end

      # Run the generators with this command.
      #
      # This will "route" the commands to the right specific generator.
      #
      def generate *args
        generator = generator_for *args
        generator.generate
      end

      #
      #
      def generator_for identifier = nil, *args
        generator_info = types[identifier.to_sym]
        generator_class = generator_info.first
        generator_for_class generator_class, identifier, *args
      rescue
        raise NotFoundException.new(self)
      end

      #
      #
      def generator_for_class klass, *args
        klass.new *args
      end
    end

  end

end