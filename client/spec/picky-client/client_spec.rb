require 'spec_helper'

describe Picky::Client do
  
  describe 'defaultize' do
    context 'no default params' do
      before(:each) do
        @base = described_class.new
      end
      it 'should return unchanged' do
        @base.defaultize( :a => :b ).should == { :a => :b }
      end
    end
    context 'default params' do
      before(:each) do
        described_class.default_params 'c' => 'd'
        @base = described_class.new
      end
      after(:each) do
        described_class.default_params
      end
      it 'should return changed' do
        @base.defaultize( 'a' => 'b' ).should == { 'a' => 'b', 'c' => 'd' }
      end
      it 'should override the default' do
        @base.defaultize( 'c' => 'b' ).should == { 'c' => 'b' }
      end
    end
  end
  
  describe 'Base' do
    before(:each) do
      @base = described_class.new
    end
    it 'should have a default_configuration method' do
      lambda { @base.default_configuration }.should_not raise_error
    end
    it 'should return a default configuration hash' do
      @base.default_configuration.should == { :host => 'localhost', :port => 8080, :path => '/searches'}
    end
    it 'should have a default_params method' do
      lambda { @base.default_params }.should_not raise_error
    end
    it 'should return an empty params hash' do
      @base.default_params.should == {}
    end
  end

  describe "Client" do
    let(:client)  { described_class.new }
    
    describe "defaults" do
      it "should set host to 'localhost'" do
        client.host.should == 'localhost'
      end
      it "should set port to the right value" do
        client.port.should == 8080
      end
      it "should set path correctly" do
        client.path.should == '/searches'
      end
    end

    describe "cattr_accessors" do
      let(:client) { described_class.new :host => :some_host, :port => :some_port, :path => :some_path }
      it "should have a writer for the host" do
        client.host = :some_host
        client.host.should == :some_host
      end
      it "should have a writer for the port" do
        client.port = :some_port
        client.port.should == :some_port
      end
      it "should have a writer for the path" do
        client.path = :some_path
        client.path.should == :some_path
      end
      it "should have a reader for the host" do
        lambda { client.host }.should_not raise_error
      end
      it "should have a reader for the port" do
        lambda { client.port }.should_not raise_error
      end
      it "should have a reader for the path" do
        lambda { client.path }.should_not raise_error
      end
    end
    
    describe 'ok search term given' do
      it 'calls send_search correctly' do
        client.should_receive(:search_unparsed).once.with('hello', {}).and_return ''

        client.search 'hello'
      end
    end
    
    describe "search" do
      before(:each) do
        client.should_receive(:search_unparsed).any_number_of_times.and_return ''
      end
      
      describe 'no search term given' do
        it "should raise an ArgumentError" do
          lambda { client.search }.should raise_error(ArgumentError)
        end
      end
      describe "with nil as search term" do
        before(:each) do
          @query = nil
        end
        it "should return a Search::Results" do
          client.search(@query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          client.search(@query).should be_empty
        end
        it 'calls send_search correctly' do
          client.should_receive(:send_search).never

          client.search @query
        end
      end
      describe "with '' as search term" do
        before(:each) do
          @query = ''
        end
        it "should return a Search::Results" do
          client.search(@query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          client.search(@query).should be_empty
        end
        it 'calls send_search correctly' do
          client.should_receive(:send_search).never

          client.search @query
        end
      end
    end
    
    describe "search_unparsed" do
      describe 'ok search term given' do
        it 'calls send_search correctly' do
          client.should_receive(:send_search).once.with :query => 'hello'
          
          client.search_unparsed 'hello'
        end
      end
      describe 'no search term given' do
        it "should raise an ArgumentError" do
          lambda { client.search_unparsed }.should raise_error(ArgumentError)
        end
      end
      describe "with nil as search term" do
        before(:each) do
          @query = nil
        end
        it "should return the right thing" do
          client.search_unparsed(@query).should == ""
        end
        it "should return an empty thing" do
          client.search_unparsed(@query).should be_empty
        end
        it 'calls send_search correctly' do
          client.should_receive(:send_search).never
          
          client.search_unparsed @query
        end
      end
      describe "with '' as search term" do
        before(:each) do
          @query = ''
        end
        it "should return a Search::Results" do
          client.search_unparsed(@query).should == ""
        end
        it "should return an empty Search::Results" do
          client.search_unparsed(@query).should be_empty
        end
        it 'calls send_search correctly' do
          client.should_receive(:send_search).never
          
          client.search_unparsed @query
        end
      end
    end
  end

end