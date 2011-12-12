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
      class Unicorn < MasterChild

        def worker_pids
          Unicorn::HttpServer::WORKERS.keys
        end

        def remove_worker wpid
          worker = Unicorn::HttpServer::WORKERS.delete(wpid) and worker.tmp.close rescue nil
        end

      end

    end

    # Aka.
    #
    # TODO
    #
    # remove_const :Unicorn if defined? Unicorn
    # Unicorn = LiveParameters::Unicorn

  end

end