require 'spec_helper'

describe Query::Tokens do
  
  before(:all) do
    Query::Qualifiers.instance << Query::Qualifier.new(:specific, [:sp, :spec])
    Query::Qualifiers.instance.prepare
  end
  
  describe 'to_solr_query' do
    context 'many tokens' do
      before(:each) do
        @tokens = Query::Tokens.new [
          Query::Token.processed('this~'),
          Query::Token.processed('is'),
          Query::Token.processed('a'),
          Query::Token.processed('sp:solr'),
          Query::Token.processed('query"')
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
      @tokens = Query::Tokens.new [@blank, @nonblank, @blank, @blank, @nonblank]
    end
    it 'should not cut it down' do
      @tokens.reject

      @tokens.instance_variable_get(:@tokens).should == [@nonblank, @nonblank]
    end
  end
  
  describe 'cap' do
    context 'one token' do
      before(:each) do
        @token = Query::Token.processed 'Token'
        @tokens = Query::Tokens.new [@token]
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
        @first = Query::Token.processed 'Hello'
        @second = Query::Token.processed 'I'
        @third = Query::Token.processed 'Am'
        @tokens = Query::Tokens.new [
          @first,
          @second,
          @third,
          Query::Token.processed('A'),
          Query::Token.processed('Token')
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
        @token = Query::Token.processed 'a*'
        @tokens = Query::Tokens.new [@token]
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
        @token = Query::Token.processed 'Token'
        @tokens = Query::Tokens.new [@token]
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
        @first = Query::Token.processed 'Hello'
        @last = Query::Token.processed 'Token'
        @tokens = Query::Tokens.new [
          @first,
          Query::Token.processed('I'),
          Query::Token.processed('Am'),
          Query::Token.processed('A'),
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

  describe 'to_s' do
    before(:each) do
      @tokens = Query::Tokens.new [
        Query::Token.processed('Hello~'),
        Query::Token.processed('I~'),
        Query::Token.processed('Am'),
        Query::Token.processed('A*'),
        Query::Token.processed('Token~')
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
        @tokens = Query::Tokens.new @internal_tokens
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