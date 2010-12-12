module Picky

  module Generators
  
    module Client

      # Generates a new Picky Sinatra Client Example.
      #
      # Example:
      #   > picky-generate sinatra my_lovely_sinatra
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
          exclaim "\"#{name}\" is a great project name! Have fun :)\n"
          exclaim ""
          exclaim "Next steps:"
          exclaim "cd #{name}"
          exclaim "bundle install"
          exclaim "unicorn -p 3000 # (optional) Or use your favorite web server."
          exclaim ""
        end
  
      end
    
    end
  
  end
  
end