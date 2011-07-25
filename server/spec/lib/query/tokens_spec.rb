require 'spec_helper'

describe Picky::Query::Tokens do
  
  describe '.processed' do
    it 'generates processed tokens from all words' do
      expected = [
        Picky::Query::Token.processed('this~'),
        Picky::Query::Token.processed('is'),
        Picky::Query::Token.processed('a'),
        Picky::Query::Token.processed('sp:solr'),
        Picky::Query::Token.processed('query"')
      ]
      
      described_class.should_receive(:new).once.with expected
      
      described_class.processed ['this~', 'is', 'a', 'sp:solr', 'query"']
    end
    it 'generates processed tokens from all words' do
      expected = [
        Picky::Query::Token.processed('this~', false),
        Picky::Query::Token.processed('is', false),
        Picky::Query::Token.processed('a', false),
        Picky::Query::Token.processed('sp:solr', false),
        Picky::Query::Token.processed('query"', false)
      ]
      
      described_class.should_receive(:new).once.with expected
      
      described_class.processed ['this~', 'is', 'a', 'sp:solr', 'query"']
    end
  end

  describe 'reject' do
    before(:each) do
      @blank    = stub :blank, :blank? => true
      @nonblank = stub :nonblank, :blank? => false
      @tokens = described_class.new [@blank, @nonblank, @blank, @blank, @nonblank]
    end
    it 'should not cut it down' do
      @tokens.reject

      @tokens.instance_variable_get(:@tokens).should == [@nonblank, @nonblank]
    end
  end
  
  describe 'cap' do
    context 'one token' do
      before(:each) do
        @token = Picky::Query::Token.processed 'Token'
        @tokens = described_class.new [@token]
      end
      it 'does not cut it down' do
        @tokens.cap 5
        
        @tokens.instance_variable_get(:@tokens).should == [@token]
      end
      it 'cuts it down' do
        @tokens.cap 0
        
        @tokens.instance_variable_get(:@tokens).should == []
      end
    end
    context 'many tokens' do
      before(:each) do
        @first  = Picky::Query::Token.processed 'Hello'
        @second = Picky::Query::Token.processed 'I'
        @third  = Picky::Query::Token.processed 'Am'
        @tokens = described_class.new [
          @first,
          @second,
          @third,
          Picky::Query::Token.processed('A'),
          Picky::Query::Token.processed('Token')
        ]
      end
      it 'should cap the number of tokens' do
        @tokens.cap 3
        
        @tokens.instance_variable_get(:@tokens).should == [@first, @second, @third]
      end
    end
  end

  describe 'partialize_last' do
    context 'special case' do
      before(:each) do
        @token = Picky::Query::Token.processed 'a*'
        @tokens = described_class.new [@token]
      end
      it 'should have a last partialized token' do
        @token.should be_partial
      end
      it 'should still partialize the last token' do
        @tokens.partialize_last

        @token.should be_partial
      end
    end
    context 'one token' do
      before(:each) do
        @token = Picky::Query::Token.processed 'Token'
        @tokens = described_class.new [@token]
      end
      it 'should not have a last partialized token' do
        @token.should_not be_partial
      end
      it 'should partialize the last token' do
        @tokens.partialize_last

        @token.should be_partial
      end
    end
    context 'many tokens' do
      before(:each) do
        @first  = Picky::Query::Token.processed 'Hello'
        @last   = Picky::Query::Token.processed 'Token'
        @tokens = described_class.new [
          @first,
          Picky::Query::Token.processed('I'),
          Picky::Query::Token.processed('Am'),
          Picky::Query::Token.processed('A'),
          @last
        ]
      end
      it 'should not have a last partialized token' do
        @last.should_not be_partial
      end
      it 'should partialize the last token' do
        @tokens.partialize_last

        @last.should be_partial
      end
      it 'should not partialize any other token' do
        @tokens.partialize_last

        @first.should_not be_partial
      end
    end
  end

  describe 'possible_combinations_in' do
    before(:each) do
      @token1 = stub :token1
      @token2 = stub :token2
      @token3 = stub :token3
      
      @tokens = described_class.new [@token1, @token2, @token3]
    end
    it 'should work correctly' do
      @token1.should_receive(:possible_combinations_in).once.with(:some_index).and_return [:combination11, :combination12]
      @token2.should_receive(:possible_combinations_in).once.with(:some_index).and_return [:combination21]
      @token3.should_receive(:possible_combinations_in).once.with(:some_index).and_return [:combination31, :combination32, :combination33]

      @tokens.possible_combinations_in(:some_index).should == [
        [:combination11, :combination12],
        [:combination21],
        [:combination31, :combination32, :combination33]
      ]
    end
    it 'should work correctly' do
      @token1.should_receive(:possible_combinations_in).once.with(:some_index).and_return [:combination11, :combination12]
      @token2.should_receive(:possible_combinations_in).once.with(:some_index).and_return nil
      @token3.should_receive(:possible_combinations_in).once.with(:some_index).and_return [:combination31, :combination32, :combination33]

      @tokens.possible_combinations_in(:some_index).should == [
        [:combination11, :combination12],
        [:combination31, :combination32, :combination33]
      ]
    end
  end

  describe 'to_s' do
    before(:each) do
      @tokens = described_class.new [
        Picky::Query::Token.processed('Hello~'),
        Picky::Query::Token.processed('I~'),
        Picky::Query::Token.processed('Am'),
        Picky::Query::Token.processed('A*'),
        Picky::Query::Token.processed('Token~')
      ]
    end
    it 'should work correctly' do
      @tokens.to_s.should == 'Hello~ I~ Am A* Token~'
    end
  end

  def self.it_should_delegate name
    describe name do
      before(:each) do
        @internal_tokens = mock :internal_tokens
        @tokens = described_class.new @internal_tokens
      end
      it "should delegate #{name} to the internal tokens" do
        proc_stub = lambda {}

        @internal_tokens.should_receive(name).once.with &proc_stub

        @tokens.send name, &proc_stub
      end
    end
  end
  # Reject is tested separately.
  #
  (Enumerable.instance_methods - [:reject]).each do |name|
    it_should_delegate name
  end
  it_should_delegate :slice!
  it_should_delegate :[]
  it_should_delegate :uniq!
  it_should_delegate :last
  it_should_delegate :length
  it_should_delegate :reject!
  it_should_delegate :size
  it_should_delegate :empty?
  it_should_delegate :each
  it_should_delegate :exit

end