module Picky
  module API
    module Source

      def extract_source thing, options = {}
        if thing.respond_to?(:each) || thing.respond_to?(:call)
          thing
        else
          return if options[:nil_ok]
          if respond_to? :name
            if @index
              location = " #{@index.name}:#{name}"
            else
              location = " #{name}"
            end
          else
            location = ''
          end
          raise ArgumentError.new(<<-ERROR)
The#{location} source should respond to either the method #each or
it can be a lambda/block, returning such a source.
ERROR
        end
      end

      # Get the actual source if it is wrapped in a time
      # capsule, i.e. a block/lambda.
      #
      def unblock_source
        @source.respond_to?(:call) ? @source.call : @source
      end

    end
  end
end