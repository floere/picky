# encoding: utf-8
#
require 'spec_helper'

require 'ostruct'

describe 'GC stats: searching' do

  PoolSpecThing = Struct.new :id, :first, :last
  
  before(:each) do
    Picky::Indexes.clear_indexes
    # GC.stress = true
  end
  after(:each) do
    # GC.stress = false
  end
  
  let(:data) do
    index = Picky::Index.new :sorted do
      category :first
      category :last
    end
    index.add PoolSpecThing.new(1, 'Abracadabra', 'Mirgel')
    index.add PoolSpecThing.new(2, 'Abraham',     'Minder')
    index.add PoolSpecThing.new(3, 'Azzie',       'Mueller')
    index
  end
  let(:search) { Picky::Search.new data }

  # TODO Study what the problem is.
  #
  # context 'without pool' do
  #   it 'runs the GC more' do
  #     try = search
  #     query = 'abracadabra mirgel'
  #     gc_runs_of do
  #       10000.times { try.search query }
  #     end.should <= 0
  #   end
  # end
  # context 'with pool' do
  #   before(:each) do
  #     Picky::Pool.install
  #   end
  #   after(:each) do
  #     # Reload since installing the Pool taints the classes.
  #     #
  #     Picky::Loader.load_framework
  #   end
  #   it 'runs the GC less' do
  #     try = search
  #     query = 'abracadabra mirgel'
  #     gc_runs_of do
  #       10000.times { try.search query; Picky::Pool.release_all }
  #     end.should <= 0 # Definitely less GC runs.
  #   end
  # end
  
end