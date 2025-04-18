require 'spec_helper'

describe Picky::Search do
  before(:each) do
    @type      = double :type
    @index     = double :some_index,
                        internal_indexed: @type,
                        each_category: [],
                        backend: Picky::Backends::Memory.new
  end

  describe 'tokenized' do
    let(:search) { described_class.new }
    it 'forwards to the tokenizer' do
      tokenizer = double :tokenizer
      search.stub tokenizer: tokenizer

      tokenizer.should_receive(:tokenize).once.with(:some_text).and_return [['some_text'], [:some_original]]

      search.tokenized :some_text
    end
  end

  describe 'boost' do
    let(:search) do
      described_class.new do
        boost %i[a b] => +3,
              %i[c d] => -1
      end
    end
    it 'works' do
      search.boosts.should == Picky::Query::Boosts.new(%i[a b] => 3, %i[c d] => -1)
    end
  end

  describe 'max_allocations' do
    let(:search) do
      described_class.new do
        max_allocations 7
      end
    end
    it 'works' do
      search.max_allocations.should == 7
    end
  end

  describe 'tokenizer' do
    context 'no tokenizer predefined' do
      let(:search) { described_class.new }
      it 'returns the default tokenizer' do
        search.tokenizer.should == Picky::Tokenizer.searching
      end
    end
    context 'tokenizer predefined' do
      let(:predefined) { double(:tokenizer, tokenize: nil) }
      context 'by way of DSL' do
        let(:search) do
          pre = predefined
          described_class.new { searching pre }
        end
        it 'returns the predefined tokenizer' do
          search.tokenizer.should == predefined
        end
      end
    end
  end

  describe 'boosts handling' do
    it 'creates a default weight when no weights are given' do
      search = described_class.new

      search.boosts.should be_kind_of(Picky::Query::Boosts)
    end
    it 'handles :weights options when not yet wrapped' do
      search = described_class.new { boost %i[a b] => +3 }

      search.boosts.should be_kind_of(Picky::Query::Boosts)
    end
    it 'handles :weights options when already wrapped' do
      search = described_class.new { boost Picky::Query::Boosts.new(%i[a b] => +3) }

      search.boosts.should be_kind_of(Picky::Query::Boosts)
    end
  end

  describe 'search' do
    before(:each) do
      @search = described_class.new
    end
    it 'forwards to search_with correctly' do
      @search.stub tokenized: :tokens

      @search.should_receive(:search_with).once.with :tokens, 20, 10, :text, nil

      @search.search :text, 20, 10
    end
    it 'forwards to search_with correctly' do
      @search.stub tokenized: :tokens

      @search.should_receive(:search_with).once.with :tokens, 20, 0, :text, nil

      @search.search :text, 20, 0
    end
    it 'forwards to search_with correctly' do
      @search.stub tokenized: :tokens

      @search.should_receive(:search_with).once.with :tokens, 20, 0, :text, true

      @search.search :text, 20, 0, unique: true
    end
    it 'uses the tokenizer' do
      @search.stub :search_with

      @search.should_receive(:tokenized).once.with :text

      @search.search :text, 20 # (unimportant)
    end
  end

  describe 'ignore_unassigned_tokens' do
    let(:search) { described_class.new @index }
    context 'by default' do
      it 'is falsy' do
        search.ignore_unassigned.should be_falsy
      end
    end
    context 'set to nothing' do
      before(:each) do
        search.ignore_unassigned_tokens
      end
      it 'is truey' do
        search.ignore_unassigned.should be_truthy
      end
    end
    context 'set to true' do
      before(:each) do
        search.ignore_unassigned_tokens true
      end
      it 'is truey' do
        search.ignore_unassigned.should be_truthy
      end
    end
    context 'set to false' do
      before(:each) do
        search.ignore_unassigned_tokens false
      end
      it 'is falsy' do
        search.ignore_unassigned.should be_falsy
      end
    end
  end

  describe 'initializer' do
    context 'with tokenizer' do
      before(:each) do
        tokenizer = double :tokenizer, tokenize: [['some_text'], ['some_original']]
        @search = described_class.new @index do
          searching tokenizer
        end
      end
      it 'should return Tokens' do
        @search.tokenized('some text').should be_kind_of(Picky::Query::Tokens)
      end
    end
  end

  describe 'to_s' do
    before(:each) do
      @index.stub name: :some_index, each_category: []
    end
    context 'without indexes' do
      before(:each) do
        @search = described_class.new
      end
      it 'works correctly' do
        @search.to_s.should == 'Picky::Search(boosts: Picky::Query::Boosts({}))'
      end
    end
    context 'with weights' do
      before(:each) do
        @search = described_class.new(@index) { boost %i[a b] => +3 }
      end
      it 'works correctly' do
        @search.to_s.should == 'Picky::Search(some_index, boosts: Picky::Query::Boosts({[:a, :b]=>3}))'
      end
    end
    context 'with special weights' do
      before(:each) do
        class RandomBoosts
          def boost_for(_combinations)
            rand
          end

          def to_s
            "#{self.class}(rand)"
          end
        end
        @search = described_class.new(@index) { boost RandomBoosts.new }
      end
      it 'works correctly' do
        @search.to_s.should == 'Picky::Search(some_index, boosts: RandomBoosts(rand))'
      end
    end
    context 'without weights' do
      before(:each) do
        @search = described_class.new(@index)
      end
      it 'works correctly' do
        @search.to_s.should == 'Picky::Search(some_index, boosts: Picky::Query::Boosts({}))'
      end
    end
  end
end
