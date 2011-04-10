class Terminal

  attr_reader :client

  def initialize given_uri
    check_highline_gem
    check_picky_client_gem

    require 'uri'
    uri = URI.parse given_uri
    unless uri.path
      uri = URI.parse "http://#{given_uri}"
    end
    unless uri.path =~ /^\//
      uri.path = "/#{uri.path}"
    end

    @searches  = 0
    @durations = 0
    @client = Picky::Client.new :host => (uri.host || 'localhost'), :port => (uri.port || 8080), :path => uri.path

    install_trap
  end
  def check_highline_gem # :nodoc:
    require "highline/system_extensions"
    extend HighLine::SystemExtensions
  rescue LoadError
    warn_gem_missing 'highline', 'the terminal interface'
    exit 1
  end
  def check_picky_client_gem # :nodoc:
    require 'picky-client'
  rescue LoadError
    warn_gem_missing 'picky-client', 'the terminal interface'
    exit 1
  end

  def install_trap
    Signal.trap('INT') do
      print "\e[100D"
      flush
      puts "\n"
      puts "Cheers. You performed #{@searches} searches, totalling #{"%.3f" % @durations} seconds."
      print "\e[100D"
      flush
      exit
    end
  end

  def flush
    STDOUT.flush
  end
  def left amount = 1
    print "\e[#{amount}D"
    flush
  end
  def right amount = 1
    print "\e[#{amount}C"
    flush
  end
  def move_to position
    relative = position - @cursor_offset
    if relative > 0
      right relative
    else
      left relative
    end
    @cursor_offset = position
    flush
  end
  def backspace
    @current_text.chop!
    print "\e[1D"
    print " "
    print "\e[1D"
    flush
  end
  def write text
    print text
    @cursor_offset += text.size
    flush
  end
  def type_search character
    @current_text << character
    write character
  end
  def write_results results
    move_to 0
    write "%9d" % (results && results.total || 0)
    move_to 10 + @current_text.size
  end
  def move_to_ids
    move_to 10 + @current_text.size + 2
  end
  def write_ids results
    move_to_ids
    write "=> #{results.total ? results.ids : []}"
  end
  def clear_ids
    move_to_ids
    write " "*200
  end
  def log results
    @searches += 1
    @durations += (results[:duration] || 0)
  end
  def search full = false
    client.search @current_text, :ids => (full ? 20 : 0)
  end
  def search_and_write full = false
    results = search full
    results.extend Picky::Convenience

    log results

    full ? write_ids(results) : clear_ids

    write_results results
  end

  def run
    puts "Break with Ctrl-C."

    @current_text  = ''
    @cursor_offset = 0
    @last_ids      = ''
    move_to 10
    search_and_write

    loop do
      input = get_character

      case input
      when 127
        backspace
        search_and_write
      when 13
        search_and_write true
      else
        type_search input.chr
        search_and_write
      end
    end
  end

end