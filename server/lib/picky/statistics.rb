# encoding: utf-8
#
require_relative 'analyzer'

module Picky

  # Gathers various statistics.
  #
  class Statistics

    def initialize
      @indexes = ["\033[1mIndexes analysis\033[m:"]
    end

    def preamble
      loc = lines_of_code File.open('app/application.rb').read

      @preamble ||= <<-PREAMBLE
  \033[1mApplication(s)\033[m
    Definition LOC:  #{"%4d" % loc}
    Indexes defined: #{"%4d" % Indexes.size}
  PREAMBLE
    end

    # Gathers information about the application.
    #
    def application
      preamble
      @application = Application.apps.map &:indented_to_s
    end

    # Gathers information about the indexes.
    #
    def analyze object
      object.each_category do |category|
        @indexes << <<-ANALYSIS
  #{"#{category.index_name}".indented_to_s}\n
  #{"#{category.name}".indented_to_s(4)}\n
  #{"exact\n#{Analyzer.new.analyze(category.exact).indented_to_s}".indented_to_s(6)}\n
  #{"partial\n#{Analyzer.new.analyze(category.partial).indented_to_s}".indented_to_s(6)}
  ANALYSIS
      end
    end

    # Outputs all gathered statistics.
    #
    def to_s
      <<-STATS

  Picky Configuration:

  #{[@preamble, @application, @indexes.join("\n")].compact.join("\n")}
  STATS
    end

    # Internal methods.
    #

    def lines_of_code text
      text.scan(/^\s*[^#\s].*$/).size
    end

  end

end