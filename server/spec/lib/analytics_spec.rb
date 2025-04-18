# encoding: utf-8

require 'spec_helper'

# Not loaded by default.
#
require_relative '../../lib/picky/analytics'

describe Picky::Analytics do
  attr_reader :index1, :index2

  Item = Struct.new :id, :text

  before(:all) do
    @index1 = Picky::Index.new :index1 do
      source [
        Item.new(1, 'test one'),
        Item.new(2, 'test two'),
      ]
      category :text
    end
    @index1.index

    @index2 = Picky::Index.new :index2 do
      source [
        Item.new(3, 'test three'),
        Item.new(4, 'test four'),
      ]
      category :text
    end
    @index2.index
    @index2
  end

  let(:analytics) { described_class.new index1, index2 }

  it 'can be initialized' do
    analytics # La-zee
  end

  it 'saves the indexes' do
    analytics.indexes.should be_kind_of(Picky::Indexes)
  end

  describe 'tokens' do
    it 'offers the method' do
      analytics.tokens
    end
    it 'calculates the number of tokens correctly' do
      analytics.tokens.should == 24
    end
  end

  describe 'ids' do
    it 'offers the method' do
      analytics.ids
    end
    it 'calculates the number of ids correctly' do
      analytics.ids.should == 32
    end
  end
end
