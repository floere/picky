module Picky

  class Scheduler

    attr_reader :parallel

    def initialize options = {}
      @parallel        = options[:parallel]
      @on_finish_queue = []

      configure
    end

    def configure
      if fork?
        def schedule &block
          scheduler.schedule &block
        end

        def finish
          scheduler.join
          finish!
        end

        def scheduler
          @scheduler ||= Procrastinate::Scheduler.start
        end
      else
        def schedule
          yield
        end

        def finish
          finish!
        end
      end
    end

    def on_finish &block
      @on_finish_queue << block
    end
    def finish!
      @on_finish_queue.each &:call
    end

    def fork?
      parallel && Process.respond_to?(:fork)
    end

  end

end