# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Similarity::None do

  before(:each) do
    @similarity = described_class.new
  end
  
  describe "saved?" do
    it "returns the right answer" do
      @similarity.saved?.should == false
    end
  end
  
  describe 'encode' do
    it 'should always return nil' do
      @similarity.encoded(:whatever).should == nil
    end
  end

  describe 'generate_from' do
    it 'should return an empty hash, always' do
      @similarity.generate_from(:anything).should == {}
    end
  end

end