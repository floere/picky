module Picky

  # Indexes indexing.
  #
  class Indexes

    extend Helpers::Indexing

    instance_delegate :clear,
                      :tokenizer

    each_delegate :clear,
                  :to => :indexes

    #
    #
    def self.index scheduler = Scheduler.new
      timed_indexing scheduler do
        instance.index scheduler
      end
    end

    #
    #
    def index scheduler = Scheduler.new
      results = indexes.map { |index| index.prepare scheduler }.flatten

      until results.empty?
        result = results.find &:ready?
        next unless result

        index, category = result.value

        p index.backtrace if index.respond_to? :message

        specific = self[index]
        specific = specific[category] if category
        specific.cache scheduler

        results.delete result
      end

      scheduler.finish
    end

    #
    #
    def tokenizer
      Tokenizer.index_default
    end

  end

end