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
          exclaim "Setting up Picky Sinatra Client/Server \"#{name}\"."
          create_target_directory
          copy_all_files expand_prototype_path('server/shared')
          copy_all_files
          exclaim "\"#{name}\" is a great project name! Have fun :)\n"
          exclaim ""
          exclaim "Next steps:"
          exclaim "1. cd #{name}"
          exclaim "2. bundle install"
          exclaim "3. rake index"
          exclaim "4. unicorn -c unicorn.rb"
          exclaim "5. open http://localhost:8080/"
          exclaim "6. rake todo      # (optional) shows you where Picky needs input from you"
          exclaim "                  #            if you want to define your own search."
        end

      end

    end

  end

end