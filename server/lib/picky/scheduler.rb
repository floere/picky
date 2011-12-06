module Picky

  class Scheduler

    attr_reader :parallel

    def initialize options = {}
      @parallel = options[:parallel]

      configure
    end

    def configure
      if fork?
        def schedule &block
          scheduler.schedule &block
        end

        def finish
          scheduler.join
        end

        def scheduler
          @scheduler ||= Procrastinate::Scheduler.start
        end
      else
        def schedule
          yield
        end

        def finish
          # Don't do anything.
        end
      end
    end

    def fork?
      parallel && Process.respond_to?(:fork)
    end

  end

end