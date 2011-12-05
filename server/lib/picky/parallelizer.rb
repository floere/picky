module Picky

  Infinity = 1.0/0

  # Parallel executor.
  #
  # Call its #schedule method with a block to
  # add some work to its queue.
  #
  # Call its #start method to get it working.
  # The #start method will block until work
  # capacity is freed.
  #
  class Parallelizer

    attr_reader :processes,
                :max_processes,
                :queue

    attr_accessor :processing

    # Processes defines how many processes will be used.
    #
    # Default is as many as there are processors.
    #
    def initialize options = {}
      @processes     = options[:processes]
      @max_processes = @processes || [number_of_cores, options[:max] || Infinity].min
      @queue         = options[:queue] || []
      @processing    = 0
    end

    # Schedule a block for later work.
    #
    # Also starts immediately if work is given.
    #
    def schedule &block
      return unless block_given?
      queue << block
      start
    end

    # Start work.
    #
    # Returns as soon as capacity is free.
    #
    def start
      return if queue.empty?

      if fork?
        loop do
          if work?
            # Get the next element
            #
            work = queue.shift
            break unless work
            self.processing += 1

            # Fork and work.
            #
            Process.fork &work
          else
            # No work, so we return.
            #
            return
          end

          # Block and wait for any child to finish.
          #
          begin
            Process.wait 0
          rescue Errno::ECHILD => e
            break
          ensure
            self.processing -= 1
          end
        end
      else
        # No forking possible, so we just do "one work".
        #
        work = queue.shift
        work.call
      end
    end

    # Do work if there is another element in the queue.
    #
    def work?
      !queue.empty?
    end

    # Do not fork if there is just one processor,
    # or as in Windows, if there isn't the
    # possibility of forking.
    #
    def fork?
      max_processes > 1 && Process.respond_to?(:fork)
    end

    # Gets the number of cores depending on OS.
    #
    def number_of_cores
      extract_cores_for actual_platform
    end
    # Extracts the number of cores for the given os name.
    #
    # Note: Default is 1.
    #
    def extract_cores_for os
      code_to_execute = os_to_core_mapping[os]
      code_to_execute && code_to_execute.call.to_i || 1
    end
    # Extracts the platform os from the platform.
    #
    # Note: Could also use 'rbconfig'.
    #
    def actual_platform
      matched = platform.match(/-\b([a-z]*)/)
      matched && matched[1]
    end
    # Returns a mapping
    #   os_name => lambda_which_returns_a_number_of_cores
    #
    @@number_of_cores = {
      'darwin' => lambda { `system_profiler SPHardwareDataType | grep -i 'Total Number [oO]f Cores'`.gsub(/[^\d]/, '') },
      'linux'  => lambda { `grep -ci ^processor /proc/cpuinfo` }
    }
    def os_to_core_mapping
      @@number_of_cores
    end
    def platform
      RUBY_PLATFORM
    end

  end

end