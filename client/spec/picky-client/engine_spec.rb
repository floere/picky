require 'spec_helper'

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
    describe "send_search" do
      before(:each) do
        Net::HTTP.stub! :get => "{\"allocations\":[[\"c\",17.53,275179,[[\"name\",\"s*\",\"s\"]],[]],[\"c\",15.01,164576,[[\"category\",\"s*\",\"s\"]],[]],[\"p\",12.94,415634,[[\"street\",\"s*\",\"s\"]],[]],[\"p\",12.89,398247,[[\"name\",\"s*\",\"s\"]],[]],[\"p\",12.67,318912,[[\"city\",\"s*\",\"s\"]],[]],[\"p\",12.37,235933,[[\"first_name\",\"s*\",\"s\"]],[]],[\"p\",11.76,128259,[[\"maiden_name\",\"s*\",\"s\"]],[]],[\"p\",11.73,124479,[[\"occupation\",\"s*\",\"s\"]],[]],[\"c\",11.35,84807,[[\"street\",\"s*\",\"s\"]],[]],[\"c\",11.15,69301,[[\"city\",\"s*\",\"s\"]],[]],[\"p\",4.34,77,[[\"street_number\",\"s*\",\"s\"]],[]],[\"c\",2.08,8,[[\"street_number\",\"s*\",\"s\"]],[]],[\"c\",1.61,5,[[\"adword\",\"s*\",\"s\"]],[]]],\"offset\":0,\"duration\":0.04,\"total\":2215417}"
      end
      it "should return a parsed hash" do
        @full.send_search(:query => 'something').should == {:allocations=>[["c", 17.53, 275179, [["name", "s*", "s"]], []], ["c", 15.01, 164576, [["category", "s*", "s"]], []], ["p", 12.94, 415634, [["street", "s*", "s"]], []], ["p", 12.89, 398247, [["name", "s*", "s"]], []], ["p", 12.67, 318912, [["city", "s*", "s"]], []], ["p", 12.37, 235933, [["first_name", "s*", "s"]], []], ["p", 11.76, 128259, [["maiden_name", "s*", "s"]], []], ["p", 11.73, 124479, [["occupation", "s*", "s"]], []], ["c", 11.35, 84807, [["street", "s*", "s"]], []], ["c", 11.15, 69301, [["city", "s*", "s"]], []], ["p", 4.34, 77, [["street_number", "s*", "s"]], []], ["c", 2.08, 8, [["street_number", "s*", "s"]], []], ["c", 1.61, 5, [["adword", "s*", "s"]], []]], :offset=>0, :duration=>0.04, :total=>2215417}
      end
      it "should be fast" do
        GC.disable
        Benchmark.realtime { @full.send_search(:query => 'something') }.should < 0.00015
        GC.enable
      end
    end
    
    describe "defaults" do
      it "should set host to 'localhost'" do
        @full.host.should == 'localhost'
      end
      it "should set port to the right value" do
        @full.port.should == 8080
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
      describe 'ok search term given' do
        it 'calls send_search correctly' do
          @full.should_receive(:send_search).once.with :query => 'hello'
          
          @full.search 'hello'
        end
      end
      describe 'no search term given' do
        it "should raise an ArgumentError" do
          lambda { @full.search }.should raise_error(ArgumentError)
        end
      end
      describe "with nil as search term" do
        before(:each) do
          @query = nil
        end
        it "should return a Search::Results" do
          @full.search(@query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @full.search(@query).should be_empty
        end
        it 'calls send_search correctly' do
          @full.should_receive(:send_search).never
          
          @full.search @query
        end
      end
      describe "with '' as search term" do
        before(:each) do
          @query = ''
        end
        it "should return a Search::Results" do
          @full.search(@query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @full.search(@query).should be_empty
        end
        it 'calls send_search correctly' do
          @full.should_receive(:send_search).never
          
          @full.search @query
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
      it "should set port to the right value" do
        @live.port.should == 8080
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
      describe 'ok search term given' do
        it 'calls send_search correctly' do
          @live.should_receive(:send_search).once.with :query => 'hello'
          
          @live.search 'hello'
        end
      end
      describe 'no search term given' do
        it "should raise an ArgumentError" do
          lambda { @live.search }.should raise_error(ArgumentError)
        end
      end
      describe "with nil as search term" do
        before(:each) do
          @query = nil
        end
        it "should return a Search::Results" do
          @live.search(@query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @live.search(@query).should be_empty
        end
        it 'calls send_search correctly' do
          @live.should_receive(:send_search).never
          
          @live.search @query
        end
      end
      describe "with '' as search term" do
        before(:each) do
          @query = ''
        end
        it "should return a Search::Results" do
          @live.search(@query).should be_kind_of(Hash)
        end
        it "should return an empty Search::Results" do
          @live.search(@query).should be_empty
        end
        it 'calls send_search correctly' do
          @live.should_receive(:send_search).never
          
          @live.search @query
        end
      end
    end
  end

end