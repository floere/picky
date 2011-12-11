module Picky

  module Generators

    # Selects the right generator.
    #
    class Selector

      attr_reader :types

      def initialize
        @types = {
          :client               => [Client::Sinatra, :sinatra_client_name],
          :server               => [Server::Sinatra, :sinatra_server_name],
          :all_in_one           => [AllInOne::Sinatra, :"directory_name (use e.g. for Heroku)"]
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