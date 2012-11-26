module Picky

  module Generators

    module Client

      # Generates a new Picky Sinatra Client Example.
      #
      # Example:
      #   > picky-generate sinatra_client my_lovely_sinatra
      #
      class Sinatra < Picky::Generators::Base

        def initialize identifier, name, *args
          super identifier, name, 'client/sinatra', *args
        end

        #
        #
        def generate
          generate_for "Sinatra Client",
          [
            'shared/both',
            'shared/client'
          ],
          [
            "cd #{name}",
            "bundle install",
            "rake index",
            "unicorn -p 3000 # (optional) Or use your favorite web server.",
            "open http://localhost:3000/",
            "rake todo # (optional) Shows you where Picky needs input from you."
          ]
        end

      end

    end

  end

end