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
          exclaim "Setting up Picky Sinatra Client \"#{name}\"."
          create_target_directory
          copy_all_files
          copy_all_files expand_prototype_path('shared/both')
          copy_all_files expand_prototype_path('shared/client')
          exclaim "\"#{name}\" is a great project name! Have fun :)\n"
          exclaim ""
          exclaim "Next steps:"
          exclaim "1. cd #{name}"
          exclaim "2. bundle install"
          exclaim "3. unicorn -p 3000 # (optional) Or use your favorite web server."
          exclaim "4. open http://localhost:3000"
          exclaim ""
        end

      end

    end

  end

end