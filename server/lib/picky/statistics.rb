# encoding: utf-8
#

# Gathers various statistics.
#
class Statistics # :nodoc:all

  def self.instance
    @statistics ||= new
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
  def analyze
    preamble

    @indexes = ["\033[1mIndexes analysis\033[m:"]
    Indexes.analyze.each_pair do |name, index|
      @indexes << <<-ANALYSIS
#{"#{name}:".indented_to_s}:
#{"exact:\n#{index[:exact].indented_to_s}".indented_to_s(4)}
#{"partial*:\n#{index[:partial].indented_to_s}".indented_to_s(4)}
ANALYSIS
    end
    @indexes = @indexes.join "\n"
  end

  # Outputs all gathered statistics.
  #
  def to_s
    <<-STATS

Picky Configuration:

#{[@preamble, @application, @indexes].compact.join("\n")}
STATS
  end

  # Internal methods.
  #

  def lines_of_code text
    text.scan(/^\s*[^#\s].*$/).size
  end

end