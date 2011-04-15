module Picky

  # A simple terminal based search.
  #
  class Cursed # :nodoc:all

    require 'curses'
    include Curses

    attr_reader :client

    def initialize given_uri, id_amount = nil
      check_picky_client_gem

      init_screen
      curs_set 1
      stdscr.keypad(true)

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
      @id_amount     = id_amount && Integer(id_amount) || 20
      @client        = Picky::Client.new :host => (uri.host || 'localhost'), :port => (uri.port || 8080), :path => uri.path

      install_trap
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
        move_to_error
        puts "Performed #{@searches} searches (#{"%.3f" % @durations} seconds)."
        sleep 1
        exit
      end
    end

    # Positioning.
    #
    def move_to_counts
      setpos 3, 0
    end
    def move_to_input
      setpos 3, (12 + @current_text.size)
    end
    def move_to_results
      setpos 4, 12
    end
    def move_to_error
      setpos 5, 0
    end

    # Delete one character.
    #
    def backspace
      chop_text
      move_to_input
      clrtoeol
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
    end

    # Write the result ids.
    #
    def write_results results
      move_to_results
      addstr "#{results.total ? results.ids(@id_amount) : []}"
      move_to_input
    rescue StandardError => e
      p e.message
      p e.backtrace
    end
    # Clear the result ids.
    #
    def clear_results
      move_to_results
      clrtoeol
      move_to_input
    end

    # Write the amount of result ids.
    #
    def write_counts results
      move_to_counts
      addstr "%11d" % (results && results.total || 0)
      move_to_input
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

      clear_error
      log results

      full ? write_results(results) : clear_results

      write_counts results
      move_to_input
    rescue Errno::ECONNREFUSED => e
      error "Please start a Picky server listening to #{@client.path}."
    rescue Yajl::ParseError => e
      error "Got a 404. Maybe the path #{@client.path} isn't a correct one?"
    end

    # Display an error text.
    #
    def error text
      move_to_error
      flash
      addstr text
      move_to_input
    end
    def clear_error
      move_to_error
      addstr @error_clear_string ||= " "*80
      move_to_input
    end

    # Display an intro text.
    #
    def intro
      addstr "Type and see the result count update. Press enter for the first #{@id_amount} result ids."
      setpos 1, 0
      addstr "Break with Ctrl-C."
      setpos 2, 0
    end

    # Run the terminal.
    #
    # Note: Uses a simple loop to handle input.
    #
    def run
      intro

      move_to_input
      search_and_write

      loop do
        input = getch

        case input
        when 10 # Curses::Key::ENTER
          search_and_write true
        when 127 # Curses::Key::BACKSPACE
          delch
          backspace
          search_and_write
        when (256..1000000)

        else
          type_search input.chr
          search_and_write
        end
      end
    end

  end

end