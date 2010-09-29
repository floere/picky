require File.dirname(__FILE__) + '/../spec_helper'

describe Picky::Client do
  
  describe 'defaultize' do
    context 'no default params' do
      before(:each) do
        @base = Picky::Client::Base.new
      end
      it 'should return unchanged' do
        @base.defaultize( :a => :b ).should == { :a => :b }
      end
    end
    context 'default params' do
      before(:each) do
        Picky::Client::Base.default_params 'c' => 'd'
        @base = Picky::Client::Base.new
      end
      after(:each) do
        Picky::Client::Base.default_params
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
      @base = Picky::Client::Base.new
    end
    it 'should have a default_configuration method' do
      lambda { @base.default_configuration }.should_not raise_error
    end
    it 'should return an empty configuration hash' do
      @base.default_configuration.should == {}
    end
    it 'should have a default_params method' do
      lambda { @base.default_params }.should_not raise_error
    end
    it 'should return an empty params hash' do
      @base.default_params.should == {}
    end
  end

  describe "Full" do
    before(:each) do
      @full = Picky::Client::Full.new
    end
    describe "defaults" do
      it "should set host to 'localhost'" do
        @full.host.should == 'localhost'
      end
      it "should set port to 4000" do
        @full.port.should == 4000
      end
      it "should set path to '/searches/full'" do
        @full.path.should == '/searches/full'
      end
    end

    describe "cattr_accessors" do
      before(:each) do
        @full = Picky::Client::Full.new :host => :some_host, :port => :some_port, :path => :some_path
      end
      it "should have a writer for the host" do
        @full.host = :some_host
        @full.host.should == :some_host
      end
      it "should have a writer for the port" do
        @full.port = :some_port
        @full.port.should == :some_port
      end
      it "should have a writer for the path" do
        @full.path = :some_path
        @full.path.should == :some_path
      end
      it "should have a reader for the host" do
        lambda { @full.host }.should_not raise_error
      end
      it "should have a reader for the port" do
        lambda { @full.port }.should_not raise_error
      end
      it "should have a reader for the path" do
        lambda { @full.path }.should_not raise_error
      end
    end

    describe "search" do
      describe "with nil as search term" do
        before(:each) do
          @query = nil
        end
        it "should return a Search::Results for bla" do
          @full.search(:query => @query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @full.search(:query => @query).should be_empty
        end
      end
      describe "with '' as search term" do
        before(:each) do
          @query = ''
        end
        it "should return a Search::Results" do
          @full.search(:query => @query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @full.search(:query => @query).should be_empty
        end
      end
    end
  end

  describe "Live" do
    before(:each) do
      @live = Picky::Client::Live.new
    end
    describe "defaults" do
      it "should set host to 'localhost'" do
        @live.host.should == 'localhost'
      end
      it "should set port to 4000" do
        @live.port.should == 4000
      end
      it "should set path to '/searches/live'" do
        @live.path.should == '/searches/live'
      end
    end

    describe "cattr_accessors" do
      it "should have a writer for the host" do
        @live.host = :some_host
        @live.host.should == :some_host
      end
      it "should have a writer for the port" do
        @live.port = :some_port
        @live.port.should == :some_port
      end
      it "should have a writer for the path" do
        @live.path = :some_path
        @live.path.should == :some_path
      end
      it "should have a reader for the host" do
        lambda { @live.host }.should_not raise_error
      end
      it "should have a reader for the port" do
        lambda { @live.port }.should_not raise_error
      end
      it "should have a reader for the path" do
        lambda { @live.path }.should_not raise_error
      end
    end

    describe "search" do
      describe "with nil as search term" do
        before(:each) do
          @query = nil
        end
        it "should return a Search::Results" do
          @live.search(:query => @query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @live.search(:query => @query).should be_empty
        end
      end
      describe "with '' as search term" do
        before(:each) do
          @query = ''
        end
        it "should return a Search::Results" do
          @live.search(:query => @query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @live.search(:query => @query).should be_empty
        end
      end
    end
  end

end