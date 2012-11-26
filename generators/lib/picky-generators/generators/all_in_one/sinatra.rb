module Picky

  module Generators

    module AllInOne

      # Generates a new Picky Sinatra/Unicorn combined Client/Server Example.
      #
      # Example:
      #   > picky-generate all_in_one my_client_server_directory
      #
      class Sinatra < Picky::Generators::Base

        def initialize identifier, name, *args
          super identifier, name, 'all_in_one/sinatra', *args
        end

        #
        #
        def generate
          generate_for "Sinatra Client/Server",
          [
            'shared/server',
            'shared/both',
            'shared/client'
          ],
          [
            "cd #{name}",
            "bundle install",
            "rake index",
            "unicorn -c unicorn.rb",
            "open http://localhost:8080/",
            "rake todo # (optional) Shows you where Picky needs input from you."
          ]
        end

      end

    end

  end

end