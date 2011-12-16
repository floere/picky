module Picky

  # This is very optional.
  # Only load if the user wants it.
  #
  module Interfaces

    module LiveParameters

      # This is an interface that provides the user of
      # Picky with the possibility to change parameters
      # while the Application is running.
      #
      class MasterChild

        def initialize
          @child, @parent = IO.pipe
          start_master_process_thread
        end

        # This runs a thread that listens to child processes.
        #
        def start_master_process_thread
          # This thread is stopped in the children.
          #
          Thread.new do
            loop do
              IO.select([@child], nil, nil, 2) or next
              result = @child.gets ';;;'
              pid, configuration_hash = eval result
              next unless Hash === configuration_hash
              next if configuration_hash.empty?
              exclaim "Trying to update MASTER configuration."
              try_updating_configuration_with configuration_hash
              kill_each_worker_except pid

              # Fails hard on an error.
              #
            end
          end
        end

        # Taken from Unicorn.
        #
        def kill_each_worker_except pid
          worker_pids.each do |wpid|
            next if wpid == pid
            kill_worker :KILL, wpid
          end
        end
        def kill_worker signal, wpid
          Process.kill signal, wpid
          exclaim "Killing worker ##{wpid} with signal #{signal}."
        rescue Errno::ESRCH
          remove_worker wpid
        end

        # Updates any parameters with the ones given and
        # returns the updated params.
        #
        # The params are a strictly defined hash of:
        #   * querying_removes_characters: Regexp
        #   * querying_stopwords:          Regexp
        #   * querying_splits_text_on:     Regexp
        #
        # This first tries to update in the child process,
        # and if successful, in the parent process
        #
        def parameters configuration_hash
          close_child
          exclaim "Trying to update worker child configuration." unless configuration_hash.empty?
          try_updating_configuration_with configuration_hash
          write_parent configuration_hash
          extract_configuration
        rescue CouldNotUpdateConfigurationError => e
          # I need to die such that my broken config is never used.
          #
          exclaim "Child process #{Process.pid} performs harakiri because of broken config."
          harakiri
          { e.config_key => :ERROR }
        end
        # Kills itself, but still answering the request honorably.
        #
        def harakiri
          Process.kill :QUIT, Process.pid
        end
        # Write the parent.
        #
        # Note: The ;;; is the end marker for the message.
        #
        def write_parent configuration_hash
          @parent.write "#{[Process.pid, configuration_hash]};;;"
        end
        # Close the child if it isn't yet closed.
        #
        def close_child
          @child.close unless @child.closed?
        end

        class CouldNotUpdateConfigurationError < StandardError
          attr_reader :config_key
          def initialize config_key, message
            super message
            @config_key = config_key
          end
        end

        # Tries updating the configuration in the child process or parent process.
        #
        def try_updating_configuration_with configuration_hash
          current_key = nil
          begin
            configuration_hash.each_pair do |key, new_value|
              exclaim "  Setting #{key} with #{new_value}."
              current_key = key
              send :"#{key}=", new_value
            end
          rescue StandardError => e
            # Catch any error and reraise as config error.
            #
            raise CouldNotUpdateConfigurationError.new current_key, e.message
          end
        end

        def extract_configuration
          {
            querying_removes_characters: querying_removes_characters,
            querying_stopwords:          querying_stopwords,
            querying_splits_text_on:     querying_splits_text_on
          }
        end

        # THINK What to do about this? Standardize the tokenizer interface,
        # then access each individual tokenizer.
        #
        def querying_removes_characters
          regexp = Tokenizer.searching.instance_variable_get :@removes_characters_regexp
          regexp && regexp.source
        end
        def querying_removes_characters= new_value
          Tokenizer.searching.removes_characters %r{#{new_value}}
        end
        def querying_stopwords
          regexp = Tokenizer.searching.instance_variable_get :@remove_stopwords_regexp
          regexp && regexp.source
        end
        def querying_stopwords= new_value
          Tokenizer.searching.instance_variable_set(:@remove_stopwords_regexp, %r{#{new_value}})
        end
        def querying_splits_text_on
          splits = Tokenizer.searching.instance_variable_get :@splits_text_on
          splits && splits.respond_to?(:source) ? splits.source : splits
        end
        def querying_splits_text_on= new_value
          splits = Tokenizer.searching.instance_variable_get :@splits_text_on
          if splits.respond_to?(:source)
            Tokenizer.searching.instance_variable_set(:@splits_text_on, %r{#{new_value}})
          else
            Tokenizer.searching.instance_variable_set(:@splits_text_on, new_value)
          end
        end

        #
        #
        def to_s
          "Suckerfish Live Interface (Use the picky-live gem to introspect)"
        end

      end

    end

  end

end