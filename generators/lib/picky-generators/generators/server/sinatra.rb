module Picky

  module Generators

    module Server

      # Generates a new Picky Sinatra/Unicorn Server Example.
      #
      # Example:
      #   > picky-generate sinatra_server my_sinatra_directory
      #
      class Sinatra < Picky::Generators::Base

        def initialize identifier, name, *args
          super identifier, name, 'server/sinatra', *args
        end

        #
        #
        def generate
          generate_for "Sinatra Server",
          [
            'shared/server',
            'shared/both'
          ],
          [
            "cd #{name}",
            "bundle install",
            "bundle exec rake index",
            "bundle exec unicorn -c unicorn.rb",
            "curl http://localhost:8080/books?query=turing",
            "rake todo # (optional) Shows you where Picky needs input from you."
          ]
        end

      end

    end

  end

end