# encoding: utf-8
#
module Picky

  module Indexers

    #
    #
    class Base

      attr_reader :index_or_category

      delegate :source,
               :to => :index_or_category

      def initialize index_or_category
        @index_or_category = index_or_category
      end

      # Starts the indexing process.
      #
      def prepare categories, scheduler = Scheduler.new
        check_source
        categories.empty
        process categories, scheduler do |prepared_file|
          notify_finished prepared_file
        end
      end

      # Explicitly reset the source to avoid caching trouble.
      #
      def reset_source
        source.reset      if source.respond_to?(:reset)
        source.reconnect! if source.respond_to?(:reconnect!)
      end

      def check_source # :nodoc:
        raise "Trying to index without a source for #{@index_or_category.name}." unless source
      end

      def notify_finished prepared_file
        timed_exclaim %Q{  "#{@index_or_category.identifier}": Tokenized -> #{prepared_file.path.gsub("#{PICKY_ROOT}/", '')}.}
      end

    end

  end

end