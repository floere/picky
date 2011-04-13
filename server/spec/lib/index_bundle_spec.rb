# encoding: utf-8
#
require 'spec_helper'

describe IndexBundle do
  
  let(:some_index) { stub :index, :name => :some_index, :internal_indexed => :indexed_index, :internal_indexing => :indexing_index }
  let(:indexes) { described_class.new }
  let(:indexed) { stub :indexed, :register => nil }
  let(:indexing) { stub :indexing, :register => nil }
  
  before(:each) do
    indexes.stub! :indexing => indexing
    indexes.stub! :indexed  => indexed
  end
  
  def self.it_delegates method, receiver
    it "delegates #{method} to #{receiver}" do
      indexes.send(receiver).should_receive(method.to_sym).once
      
      indexes.send method
    end
  end
  
  describe 'delegation' do
    it_delegates :reload, :indexed
    it_delegates :load_from_cache, :indexed
    
    it_delegates :check_caches, :indexing
    it_delegates :find, :indexing
    it_delegates :generate_cache_only, :indexing
    it_delegates :generate_index_only, :indexing
    it_delegates :index, :indexing
    it_delegates :index_for_tests, :indexing
  end
  
  describe '[]' do
    before(:each) do
      indexes.register some_index
    end
    it 'takes strings' do
      indexes['some_index'].should == some_index
    end
    it 'takes symbols' do
      indexes[:some_index].should == some_index
    end
  end
  
  describe 'register' do
    it 'registers with the indexes' do
      indexes.register some_index
      
      indexes.indexes.should == [some_index]
    end
    it 'registers with the index map' do
      indexes.register some_index
      
      indexes[some_index.name].should == some_index
    end
    it 'registers with the indexing' do
      indexing.should_receive(:register).once.with :indexing_index
      
      indexes.register some_index
    end
    it 'registers with the indexed' do
      indexed.should_receive(:register).once.with :indexed_index
      
      indexes.register some_index
    end
  end
end