require File.expand_path('../../../spec_helper', __FILE__)

require 'picky-indexes/rust/array'

describe Rust::Array do
  
  it 'can be created' do
    described_class.new
  end
  
  it 'finalizable (will run after specs)' do
    ohai = described_class.new
    ohai = nil
  end
  
  let(:empty) { described_class.new }
  let(:array) { described_class.new }
  
  describe 'with some elements' do
    before(:each) do
      5.times { |i| array << i }
    end
    describe '#first' do
      # it 'handles an empty array' do
      #   empty.first.assert == nil
      # end
      it 'is correct' do
        array.first.assert == 0
      end
    end
    describe '#last' do
      # it 'handles an empty array' do
      #   empty.last.assert == nil
      # end
      it 'is correct' do
        array.last.assert == 4
      end
    end
    describe '#length' do
      it 'handles an empty array' do
        empty.length.assert == 0
      end
      it 'is correct' do
        array.length.assert == 5
      end
    end
    describe '#size' do
      it 'handles an empty array' do
        empty.size.assert == 0
      end
      it 'is correct' do
        array.size.assert == 5
      end
    end
  end
  
  describe '#<<' do
    it 'works' do
      array << 1
    end
    # it 'actually appends' do
    #   # [].assert == array
    #
    #   array << 1
    #
    #   # assert [1] == array
    # end
  end
  describe '#shift' do
    it 'works with empty arrays' do
      empty.shift.assert == nil
    end
    it 'works' do
      array << 1
      array << 2
      array << 3
      
      array.shift.assert == 1
      array.shift.assert == 2
      array.shift.assert == 3
    end
  end
  
end