module Picky

  class Scheduler

    attr_reader :parallel

    def initialize options = {}
      @parallel = options[:parallel]
      @factor   = options[:factor] || 2

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
          @scheduler ||= create_scheduler
        end
        
        def create_scheduler
          Procrastinate::Scheduler.start Procrastinate::SpawnStrategy::Default.new(@factor)
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
      require 'procrastinate'
      parallel && Process.respond_to?(:fork)
    rescue LoadError => e
      warn_procrastinate_missing
      return false
    end
    def warn_procrastinate_missing
      warn_gem_missing 'Procrastinate', 'parallelized indexing (with the procrastinate gem)' unless @gem_missing_warned
      @gem_missing_warned = true
    end

  end

end