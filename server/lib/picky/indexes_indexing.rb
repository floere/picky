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
      indexes.each { |index| index.prepare scheduler }
      scheduler.finish

      # timed_exclaim "Tokenizing finished, generating data for indexes from tokenized data."

      indexes.each { |index| index.cache scheduler }
      scheduler.finish
    end

    #
    #
    def tokenizer
      Tokenizer.indexing
    end

  end

end