require 'tempfile'
require 'json'

module Statistics

  class LogfileReader

    attr_reader :last_offset # in bytes
    attr_writer :path

    def exclaim text
      puts text
    end

    #
    #
    def initialize path
      @path = File.expand_path path
      check_file

      @counts = {}
      initialize_totals
      initialize_full_totals
      initialize_live_totals
      initialize_other
    end
    def check_file
      if File.exists? @path
        exclaim "Logfile #{@path} found."
      else
        raise "Log file #{@path} not found."
      end
    end

    def full
      @counts[:full] ||= {}
    end
    def live
      @counts[:live] ||= {}
    end

    def initialize_totals
      full[:total] = Count.new "^>|"
      live[:total] = Count.new "^\\.|"
    end
    def initialize_full_totals
      full[:totals] = {}
      full[:totals][0]         = Count.new "^>|.*|       0|"
      full[:totals][1]         = Count.new "^>|.*|       1|"
      full[:totals][2]         = Count.new "^>|.*|       2|"
      full[:totals][3]         = Count.new "^>|.*|       3|"
      full[:totals][:'4+']     = Count.new("^>|.*|       [4-9]|", "^>|.*|      [1-9][0-9]|") # 4-9, 10+, but less than 100
      full[:totals][:'100+']   = Count.new "^>|.*|.*|     [1-9][0-9][0-9]|"
      full[:totals][:'1000+']  = Count.new "^>|.*|.*|....[0-9]...|"

      full[:totals][:cloud]     = Count.new("^>|.*|[1-9].|",                      # allocs 10+
                                            "^>|.*|.*|......[1-9].|....|.[2-9]|") # allocs 2-9, more than 10 results
    end
    def initialize_live_totals

    end
    def initialize_other
      full[:quick]             = Count.new "^>|.\\+\\?|0\\.00....|"
      full[:long_running]      = Count.new "^>|.\\+\\?|0\\.[1-9].....|"
      full[:very_long_running] = Count.new "^>|.\\+\\?|[1-9]\\.......|"

      full[:offset]            = Count.new("^>|.*|[ 1-9][ 0-9][0-9][0-9]|", # offset 10+
                                           "^>|.*|   [1-9]")                # offset 1-9
    end

    #
    #
    def since_last
      @last_offset ||= 0

      log_offset = @last_offset
      start_time = Time.now

      with_temp_file(@last_offset) do |statistics|
        calculate_last_offset_from statistics

        full[:total].add_from statistics
        live[:total].add_from statistics

        full[:totals][0].add_from statistics
        full[:totals][1].add_from statistics
        full[:totals][2].add_from statistics
        full[:totals][3].add_from statistics

        full[:totals][:'4+'].add_from statistics
        full[:totals][:cloud].add_from statistics

        full[:totals][:'100+'].add_from statistics
        full[:totals][:'1000+'].add_from statistics

        full[:quick].add_from statistics
        full[:long_running].add_from statistics
        full[:very_long_running].add_from statistics

        full[:offset].add_from statistics
      end

      duration = Time.now - start_time
      exclaim "Parsed log from byte #{log_offset} in #{duration}s"

      @counts
    end

    def calculate_last_offset_from statistics
      @last_offset += last_offset_from statistics
    end
    def last_offset_from statistics
      `wc #{statistics}`.split(/\s+/)[3].to_i
    end

    #
    #
    def reset_from time
      with_temp_file(offset) do |statistics|
        full[:total].reset_from statistics
      end
      @counts
    end

    # Use the offset to speed up statistics gathering.
    #
    def with_temp_file offset = 0
      # Quickly return if no logs have been written since the last time.
      #
      return if last_offset_from(@path) <= last_offset

      Tempfile.open 'picky' do |temp_file|

        temp_path = temp_file.path
        `tail -c +#{offset} #{@path} > #{temp_path}`
        yield temp_path

      end
    end

  end

end