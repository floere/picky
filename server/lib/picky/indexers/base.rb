# encoding: utf-8
#
module Picky

  module Indexers

    #
    #
    class Base

      attr_reader :index_or_category

      forward :source,
              :to => :index_or_category

      def initialize index_or_category
        @index_or_category = index_or_category
      end

      # Starts the indexing process.
      #
      def prepare categories, scheduler = Scheduler.new
        source_for_prepare = source
        check source_for_prepare
        categories.empty
        process source_for_prepare, categories, scheduler do |prepared_file|
          notify_finished prepared_file
        end
      end

      # Explicitly reset the source to avoid caching trouble.
      #
      def reset source
        source.reset      if source.respond_to?(:reset)
        source.reconnect! if source.respond_to?(:reconnect!)
      end

      def check source
        raise "Trying to index without a source for #{@index_or_category.name}." unless source
      end

      def notify_finished prepared_file
        Picky.logger.tokenize @index_or_category, prepared_file
      end

    end

  end

end