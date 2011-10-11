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
    def self.forked ary_or_generator, options = {}, &block
      return if ary_or_generator.empty?
      raise "Block argument needed when running Cores.forked" unless block_given?

      ary_or_generator = ary_or_generator.sort_by { rand } if options[:randomly]
      generator        = ary_or_generator.each

      # Don't fork if there's just one element.
      #
      # TODO Remove. This is ugly.
      #
      if generator.inject(0) { |total, element| total + 1 } == 1
        generator.each do |element|
          block.call element # THINK yield generator.next results in trouble. Why?
        end
        return
      end

      # Get the maximum number of processors.
      #
      max                  = max_processors options
      currently_processing = 0

      #
      #
      loop do
        # Ramp it up to num processors.
        #
        while currently_processing < max
          currently_processing += 1

          # Get the next thing to work on.
          #
          element = next_from generator

          # If there is none, stop getting more.
          #
          break unless element

          # Fork and yield.
          #
          Process.fork do
            sleep 0.05*currently_processing
            block.call element
          end
        end

        # Block and wait for any child to finish.
        #
        begin
          Process.wait 0
        rescue Errno::ECHILD => e
          break # Stop looping.
        ensure
          currently_processing -= 1
        end
      end
    end

    # Returns nil if there is no next element or if an error occurred.
    #
    def self.next_from generator
      generator.next
    rescue StopIteration => si
      nil
    rescue StandardError => se
      puts se
      nil
    end

    # Return the number of maximum usable processors.
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