module Picky

  # A simple terminal based search.
  #
  class Terminal

    attr_reader :client

    def initialize given_uri, id_amount = nil
      check_highline_gem
      check_picky_client_gem

      require 'uri'
      uri = URI.parse given_uri

      # If the user gave a whole url without http, add that and reparse.
      #
      unless uri.path
        uri = URI.parse "http://#{given_uri}"
      end

      # If the user gave a path without / in front, add one.
      #
      unless uri.path =~ /^\//
        uri.path = "/#{uri.path}"
      end

      @searches  = 0
      @durations = 0
      @current_text  = ''
      @cursor_offset = 0
      @last_ids      = ''
      @id_amount     = id_amount && Integer(id_amount) || 20
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

    # Install the Ctrl-C handler.
    #
    def install_trap
      Signal.trap('INT') do
        print "\e[100D"
        flush
        puts "\n"
        puts "You performed #{@searches} searches, totalling #{"%.3f" % @durations} seconds."
        print "\e[100D"
        flush
        exit
      end
    end

    # Flush to STDOUT.
    #
    def flush
      STDOUT.flush
    end

    # Position cursor amount to the left.
    #
    def left amount = 1
      print "\e[#{amount}D"
      flush
    end

    # Position cursor amount to the right.
    #
    def right amount = 1
      print "\e[#{amount}C"
      flush
    end

    # Move cursor to position.
    #
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

    # Delete one character.
    #
    def backspace
      chop_text
      print "\e[1D \e[1D"
      flush
    end

    # Write the text to the input area.
    #
    def write text
      @cursor_offset += text.size
      print text
      flush
    end

    # Chop off one character.
    #
    def chop_text
      @current_text.chop!
    end

    # Add the given text to the current text.
    #
    def add_text text
      @current_text << text
    end

    # Type the given text into the input area.
    #
    def type_search character
      add_text character
      write character
    end

    # Write the amount of result ids.
    #
    def write_results results
      move_to 0
      write "%9d" % (results && results.total || 0)
      move_to 10 + @current_text.size
    end

    # Move to the id area.
    #
    def move_to_ids
      move_to 12 + @current_text.size
    end

    # Write the result ids.
    #
    def write_ids results
      move_to_ids
      write "=> #{results.total ? results.ids(@id_amount) : []}"
    rescue StandardError => e
      p e.message
      p e.backtrace
    end

    # Clear the result ids.
    #
    def clear_ids
      move_to_ids
      write @ids_clearing_string ||= " "*200
    end

    # Log a search.
    #
    def log results
      @searches += 1
      @durations += (results[:duration] || 0)
    end

    # Perform a search.
    #
    def search full = false
      client.search @current_text, :ids => (full ? @id_amount : 0)
    end

    # Perform a search and write the results.
    #
    # Handles 404s and connection problems.
    #
    def search_and_write full = false
      results = search full
      results.extend Picky::Convenience

      log results

      full ? write_ids(results) : clear_ids

      write_results results
    rescue Errno::ECONNREFUSED => e
      write "Please start a Picky server listening to #{@client.path}."
    rescue Yajl::ParseError => e
      write "Got a 404. Maybe the path #{@client.path} isn't a correct one?"
    end

    # Run the terminal.
    #
    # Note: Uses a simple loop to handle input.
    #
    def run
      puts "Type and see the result count update. Press enter for the first #{@id_amount} result ids."
      puts "Break with Ctrl-C."

      search_and_write

      loop do
        input = get_character

        case input
        when 127
          backspace
          search_and_write
        when 13
          search_and_write true
        else # All other.
          type_search input.chr
          search_and_write
        end
      end
    end

  end

end