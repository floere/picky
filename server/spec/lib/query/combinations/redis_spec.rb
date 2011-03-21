# coding: utf-8
#
require 'spec_helper'

describe Internals::Query::Combinations::Redis do

  before(:each) do
    @combinations_ary = stub :combinations_ary
    
    @combinations = described_class.new @combinations_ary
  end
  
  describe 'ids' do
    context 'empty combinations' do
      let(:combinations) { described_class.new [] }
      it 'does something' do
        combinations.ids(20,0).should == []
      end
    end
    context 'non-empty' do
      let(:combination) { stub :combination, :identifier => :some_combination }
      let(:combinations) { described_class.new [combination] }
      let(:redis) { stub :redis }
      before(:each) do
        combinations.stub! :redis => redis
        
        combinations.stub! :host => 'some.host'
        combinations.stub! :pid  => 12345
      end
      it 'calls the redis backend correctly' do
        redis.should_receive(:zinterstore).once.ordered.with :"some.host:12345:picky:result", ["some_combination"]
        redis.should_receive(:zrange).once.ordered.with :"some.host:12345:picky:result", 0, 20
        redis.should_receive(:del).once.ordered.with :"some.host:12345:picky:result"
        
        combinations.ids 20,0
      end
    end
  end
  
  describe 'pid' do
    it "returns the Process' pid" do
      Process.stub! :pid => 12345

      @combinations.pid.should == 12345
    end
  end
  
  describe 'host' do
    before(:each) do
      @combinations.class.stub! :extract_host => 'some.host'
    end
    it 'returns the host' do
      @combinations.host.should == 'some.host'
    end
  end
  
  describe "pack_into_allocation" do
    it "return an Allocation" do
      @combinations.pack_into_allocation(:some_result_identifier).should be_kind_of(Internals::Query::Allocation)
    end
    it "returns an Allocation with specific result_identifier" do
      @combinations.pack_into_allocation(:some_result_identifier).result_identifier.should == :some_result_identifier
    end
  end
  
  describe "to_result" do
    before(:each) do
      @combination1 = stub :combination1, :to_result => :result1
      @combination2 = stub :combination2, :to_result => :result2
      
      @combinations_ary = [@combination1, @combination2]
      
      @combinations = described_class.new @combinations_ary
    end
    it "resultifies the combinations" do
      @combinations.to_result.should == [:result1, :result2]
    end
  end
  
  describe "weighted_score" do
    it "uses the weights' score method" do
      weights = stub :weights
      weights.should_receive(:score).once.with @combinations_ary
      
      @combinations.weighted_score weights
    end
  end
  
  describe "total_score" do
    before(:each) do
      @combination1 = stub :combination1, :weight => 3.14
      @combination2 = stub :combination2, :weight => 2.76
      
      @combinations_ary = [@combination1, @combination2]
      
      @combinations = described_class.new @combinations_ary
    end
    it "sums the scores" do
      @combinations.total_score.should == 5.90
    end
  end
  
  describe "calculate_score" do
    before(:each) do
      @combinations.stub! :total_score => 0
      @combinations.stub! :weighted_score => 0
    end
    it "first sums, then weighs" do
      @combinations.should_receive(:total_score).once.ordered.and_return 0
      @combinations.should_receive(:weighted_score).once.ordered.and_return 0
      
      @combinations.calculate_score :anything
    end
    it "calls sum_score" do
      @combinations.should_receive(:total_score).once.with.and_return 0
      
      @combinations.calculate_score :anything
    end
    it "calls sum_score" do
      @combinations.should_receive(:weighted_score).once.with(:weights).and_return 0
      
      @combinations.calculate_score :weights
    end
  end
  
  describe 'hash' do
    it "delegates to the combinations array" do
      @combinations_ary.should_receive(:hash).once.with
      
      @combinations.hash
    end
  end
  
  describe 'remove' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = described_class.new [@combination1, @combination2, @combination3]
    end
    it 'should remove the combinations' do
      @combinations.remove([:any]).should == [@combination1]
    end
  end

  describe 'keep' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = described_class.new [@combination1, @combination2, @combination3]
    end
    it 'should filter the combinations' do
      @combinations.keep([:any]).should == [@combination2, @combination3]
    end
  end
  
  describe 'generate_intermediate_result_id' do
    it 'returns the correct result id' do
      @combinations.stub! :host => 'some_hostname'
      Process.stub! :pid => 12345
      
      @combinations.generate_intermediate_result_id.should == :'some_hostname:12345:picky:result'
    end
  end

  describe "ids" do
    before(:each) do
      @combination1 = stub :combination1, :identifier => 'cat1'
      @combination2 = stub :combination2, :identifier => 'cat2'
      @combination3 = stub :combination3, :identifier => 'cat3'
      @combinations = described_class.new [@combination1, @combination2, @combination3]
    end
    it 'calls the redis client correctly' do
      # TODO
    end
  end

end