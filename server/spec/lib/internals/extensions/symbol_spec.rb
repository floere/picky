require 'spec_helper'

describe Symbol do
  
  context 'performance' do
    include Helpers::Measuring
    before(:each) do
      @token = (((0..9).to_a)*10).to_s.to_sym
    end
    it "should be fast" do
      performance_of { @token.each_subtoken { |subtoken| } }.should < 0.00065
    end
  end
  
  describe "each_subtoken" do
    context 'normal symbol' do
      before(:each) do
        @sym = :reinke
      end
      context 'no downto' do
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken do |subtoken|
            result << subtoken
          end
          result.should == [:reinke, :reink, :rein, :rei, :re, :r]
        end
      end
      context 'downto is larger than the symbol' do
        before(:each) do
          @downto = 8
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:reinke]
        end
      end
      context 'downto is exactly the same as symbol' do
        before(:each) do
          @downto = 6
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:reinke]
        end
      end
      context 'downto is smaller than the length of the symbol' do
        before(:each) do
          @downto = 4
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:reinke, :reink, :rein]
        end
      end
      context 'downto is 1' do
        before(:each) do
          @downto = 1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:reinke, :reink, :rein, :rei, :re, :r]
        end
      end
      context 'downto is 0' do
        before(:each) do
          @downto = 0
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:reinke, :reink, :rein, :rei, :re, :r]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -2
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:reinke, :reink]
        end
      end
    end
    context 'very short symbol' do
      before(:each) do
        @sym = :r
      end
      context 'no downto' do
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is larger than the symbol' do
        before(:each) do
          @downto = 8
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is exactly the same as symbol' do
        before(:each) do
          @downto = 6
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is smaller than the length of the symbol' do
        before(:each) do
          @downto = 4
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is 1' do
        before(:each) do
          @downto = 1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is 0' do
        before(:each) do
          @downto = 0
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -2
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -3
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -100
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @sym.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == [:r]
        end
      end
    end
  end
  
end