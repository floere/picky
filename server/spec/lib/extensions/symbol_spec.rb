require 'spec_helper'

describe Symbol do

  before(:each) do
    GC.disable
  end
  after(:each) do
    GC.enable
    GC.start
  end

  context 'performance' do
    include Helpers::Measuring
    it 'should be fast' do
      s = (((0..9).to_a)*10).to_s.to_sym

      timed do
        s.subtokens
      end.should <= 0.001
    end
  end

  describe "subtokens" do
    context 'normal symbol' do
      before(:each) do
        @sym = :reinke
      end
      context 'no downto' do
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens.should == [:reinke, :reink, :rein, :rei, :re, :r]
        end
      end
      context 'downto is larger than the symbol' do
        before(:each) do
          @downto = 8
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens(@downto).should == [:reinke]
        end
      end
      context 'downto is exactly the same as symbol' do
        before(:each) do
          @downto = 6
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens(@downto).should == [:reinke]
        end
      end
      context 'downto is smaller than the length of the symbol' do
        before(:each) do
          @downto = 4
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens(@downto).should == [:reinke, :reink, :rein]
        end
      end
      context 'downto is 1' do
        before(:each) do
          @downto = 1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens(@downto).should == [:reinke, :reink, :rein, :rei, :re, :r]
        end
      end
      context 'downto is 0' do
        before(:each) do
          @downto = 0
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens(@downto).should == [:reinke, :reink, :rein, :rei, :re, :r, :""]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -2
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          @sym.subtokens(@downto).should == [:reinke, :reink, :rein]
        end
      end
    end
  end

end