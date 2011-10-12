module Picky

  Infinity = 1.0/0

  # Handles processing over multiple cores.
  #
  class Cores # :nodoc:all

    # Pass it an ary or generator.
    #
    #   generator = (1..10).each
    #   forked generator, :max => 5 do |element|
    #
    #   end
    #
    # Options include:
    #  * max: Maximum # of processors to use. Default is all it can get.
    #
    def self.forked elements, options = {}, &block
      return if elements.empty?
      raise "Block argument needed when running Cores.forked" unless block_given?

      # Note: Not using a generator because Enumerator#each
      # is exhibiting problems in some Rubies on some OSs
      # (see e.g. http://redmine.ruby-lang.org/issues/5003).
      #
      elements = elements.dup
      elements = elements.sort_by { rand } if options[:randomly]

      # Get the maximum number of processors.
      #
      max = max_processors options

      # Do not fork if there is just one processor,
      # or as in Windows, just a single instance that
      # can do work.
      #
      if max == 1
        elements.each &block
      else
        processing = 0

        loop do
          while processing < max
            # Get the next element
            #
            element = elements.shift
            break unless element
            processing += 1

            # Fork and yield.
            #
            Process.fork do
              sleep 0.05*processing
              block.call element
            end
          end

          # Block and wait for any child to finish.
          #
          begin
            Process.wait 0
          rescue Errno::ECHILD => e
            break
          ensure
            processing -= 1
          end
        end
      end

    end

    # Return the number of maximum usable processors.
    #
    # Options
    #   max: The maximum amount of cores used.
    #
    def self.max_processors options = {}
      options[:amount] || [number_of_cores, (options[:max] || Infinity)].min
    end

    # Gets the number of cores depending on OS.
    #
    def self.number_of_cores
      extract_cores_for actual_platform
    end
    # Extracts the platform os from the platform.
    #
    # Note: Could also use 'rbconfig'.
    #
    def self.actual_platform
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
    def self.os_to_core_mapping
      @@number_of_cores
    end
    # Extracts the number of cores for the given os name.
    #
    # Note: Default is 1.
    #
    def self.extract_cores_for os
      code_to_execute = os_to_core_mapping[os]
      code_to_execute && code_to_execute.call.to_i || 1
    end
    def self.platform
      RUBY_PLATFORM
    end

  end

end