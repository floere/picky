require 'tempfile'
require 'json'

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
  end
  def check_file
    if File.exists? @path
      exclaim "Logfile #{@path} found."
    else
      raise "Log file #{@path} not found."
    end
  end
  
  def reset
    @last_offset = 0
  end

  def since log_offset = nil
    @last_offset = log_offset || 0
    
    start_time = Time.now

    # Add all the data to the results.
    #
    results = []
    with_temp_file(log_offset) do |statistics|
      calculate_last_offset_from statistics
      
      File.open(statistics, 'r') do |file|
        while line = file.gets
          next if line =~ /\A\s*\#/
          results << process(line) rescue nil
        end
      end
    end

    duration = Time.now - start_time
    exclaim "Parsed log from byte #{log_offset} in #{duration}s"
      
    results
  end

  #
  #
  def since_last
    since @last_offset
  end
  
  # Processes one line and returns an array.
  #
  def process line
    [
      line[2,  19],
      Float(line[22, 8]),
      line[31, 50].gsub!(/\s*\z/, ''),
      Integer(line[82, 8]),
      Integer(line[92, 3]),
      Integer(line[96, 2])
    ]
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