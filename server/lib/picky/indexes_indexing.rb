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
        results.delete_if do |result|
          if result.ready?
            index, category = result.value
            specific = self[index]
            specific = specific[category] if category
            specific.cache scheduler
          end
        end
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