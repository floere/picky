# Helper methods for measuring, benchmarking, logging.
#
module Helpers
  module Measuring

    def log_performance(name, performed_on = '', &block)
      time_begin = Time.now.to_f

      lambda(&block).call

      duration = Time.now.to_f - time_begin

      # PerformanceLog.info("#{'%30s' % name}: #{'%2.10f' % duration} #{performed_on}")
      duration
    end

    # Returns a duration in seconds.
    #
    def timed(*args, &block)
      block_to_be_measured = lambda(&block)

      time_begin = Time.now.to_f

      block_to_be_measured.call(*args)

      Time.now.to_f - time_begin
    end

    def profiled_html(mode = :cpu_time, &block)
      require 'ruby-prof'

      RubyProf.measure_mode = "RubyProf::#{mode.to_s.upcase}".constantize

      result = RubyProf.profile &block

      printer = RubyProf::GraphHtmlPrinter.new(result)
      File.open('log/profiler.html', 'w') do |f|
        printer.print(f)
      end

      system 'open log/profiler.html'
    end

  end
end