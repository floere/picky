# encoding: utf-8
#
require 'spec_helper'

# We need to load the Statistics file explicitly as the Statistics
# are not loaded with the Loader (not needed in the server, only for script runs).
#
require File.expand_path '../../../lib/tasks/try', __dir__

describe Picky::Try do
  
  context 'with text' do
    let(:try) { described_class.new 'text' }
    it 'is saved correctly' do
      try.saved.should == ['text']
    end
    it 'is searched correctly' do
      try.searched.should == ['text']
    end
  end
  
  context 'with text and index' do
    before(:each) do
      Picky::Indexes.register Picky::Index.new(:index)
    end
    let(:try) { described_class.new 'text', 'index' }
    it 'is saved correctly' do
      try.saved.should == ['text']
    end
    it 'is searched correctly' do
      try.searched.should == ['text']
    end
  end
  
  context 'with text and index and category' do
    before(:each) do
      index = Picky::Index.new(:index) do
        category :category
      end
      Picky::Indexes.register index
    end
    let(:try) { described_class.new 'text', 'index', 'category' }
    it 'is saved correctly' do
      try.saved.should == ['text']
    end
    it 'is searched correctly' do
      try.searched.should == ['text']
    end
  end
  
end