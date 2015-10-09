require File.expand_path('../../../spec_helper', __FILE__)

require 'picky-indexes/rust/array'

describe Rust::Array do
  
  it 'can be created' do
    described_class.new
  end
  
  let(:array) { described_class.new }
  
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
    it 'works' do
      array.shift.assert == nil
    end
    # it 'works' do
    #   array << 1
    #   array << 2
    #   array << 3
    #
    #   array.shift.assert == 1
    #   array.shift.assert == 1
    #   array.shift.assert == 3
    # end
  end
  
end