module Picky
  class Tokenizer
    class RegexpWrapper
      def initialize(regexp)
        @regexp = regexp
        @splitter = Splitter.new @regexp
      end

      def split(text)
        @splitter.multi text
      end

      def source
        @regexp.source
      end

      def respond_to_missing?(name, include_private)
        @regexp.respond_to?(name, include_private) || super
      end

      def method_missing name, *args, &block
        @regexp.send name, *args, &block
      end
    end
  end
end
