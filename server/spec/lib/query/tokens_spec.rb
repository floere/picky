require 'spec_helper'

describe Internals::Query::Tokens do
  
  before(:all) do
    Internals::Query::Qualifiers.instance << Internals::Query::Qualifier.new(:specific, [:sp, :spec])
    Internals::Query::Qualifiers.instance.prepare
  end
  
  describe 'to_solr_query' do
    context 'many tokens' do
      before(:each) do
        @tokens = described_class.new [
          Internals::Query::Token.processed('this~'),
          Internals::Query::Token.processed('is'),
          Internals::Query::Token.processed('a'),
          Internals::Query::Token.processed('sp:solr'),
          Internals::Query::Token.processed('query"')
        ]
      end
      it 'should output a correct solr query' do
        @tokens.to_solr_query.should == 'this~0.74 is a specific:solr~0.74 query~0.78'
      end
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
        @token = Internals::Query::Token.processed 'Token'
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
        @first = Internals::Query::Token.processed 'Hello'
        @second = Internals::Query::Token.processed 'I'
        @third = Internals::Query::Token.processed 'Am'
        @tokens = Internals::Query::Tokens.new [
          @first,
          @second,
          @third,
          Internals::Query::Token.processed('A'),
          Internals::Query::Token.processed('Token')
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
        @token = Internals::Query::Token.processed 'a*'
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
        @token = Internals::Query::Token.processed 'Token'
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
        @first  = Internals::Query::Token.processed 'Hello'
        @last   = Internals::Query::Token.processed 'Token'
        @tokens = described_class.new [
          @first,
          Internals::Query::Token.processed('I'),
          Internals::Query::Token.processed('Am'),
          Internals::Query::Token.processed('A'),
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
        Internals::Query::Token.processed('Hello~'),
        Internals::Query::Token.processed('I~'),
        Internals::Query::Token.processed('Am'),
        Internals::Query::Token.processed('A*'),
        Internals::Query::Token.processed('Token~')
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