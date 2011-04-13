module Sources

  # Source wrappers can be used to rewrite data before it goes into the index.
  #
  # For example if you want to normalize data.
  #
  module Wrappers # :nodoc:all

    class Base

      attr_reader :source

      # Wraps an indexing category.
      #
      def initialize source
        @source = source
      end

      # Default is delegation for all methods
      #
      delegate :harvest, :connect_backend, :take_snapshot, :key_format, :to => :source

    end

  end

end