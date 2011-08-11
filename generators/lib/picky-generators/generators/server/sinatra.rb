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
          exclaim "Setting up Picky Sinatra Server \"#{name}\"."
          create_target_directory
          copy_all_files
          copy_all_files expand_prototype_path('server/shared')
          exclaim "\"#{name}\" is a great project name! Have fun :)\n"
          exclaim ""
          exclaim "Next steps:"
          exclaim "1. cd #{name}"
          exclaim "2. bundle install"
          exclaim "3. rake index"
          exclaim "4. unicorn -c unicorn.rb"
          exclaim "5. rake todo      # (optional) shows you where Picky needs input from you"
          exclaim "                  #            if you want to define your own search."
        end

      end

    end

  end

end