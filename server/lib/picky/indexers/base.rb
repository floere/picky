# encoding: utf-8
#
module Picky

  module Indexers

    #
    #
    class Base

      attr_reader :index_or_category

      delegate :source, :to => :index_or_category

      def initialize index_or_category
        @index_or_category = index_or_category
      end

      # Starts the indexing process.
      #
      def index categories
        process categories do |file|
          notify_finished file
        end
      end

      def notify_finished file
        timed_exclaim %Q{"#{@index_or_category.identifier}": Tokenized -> #{file.path.gsub("#{PICKY_ROOT}/", '')}.}
      end

    end

  end

end