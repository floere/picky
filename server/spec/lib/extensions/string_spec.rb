# encoding: utf-8
#
require 'spec_helper'

# Requiring text here as it's optional in Picky.
require 'text'

describe String do

  context 'performance' do
    include Picky::Helpers::Measuring
    before(:each) do
      @token = (((0..9).to_a)*10).to_s
    end
    it "is fast" do
      performance_of { @token.each_subtoken { |subtoken| } }.should < 0.00065
    end
    it 'is fast enough' do
      performance_of { @token.each_intoken { |intoken| } }.should < 0.025
    end
  end

  describe 'double_metaphone' do
    it 'returns the right code' do
      'hello'.double_metaphone.should == 'HL'
    end
  end
  describe 'metaphone' do
    it 'returns the right code' do
      'hello'.metaphone.should == 'HL'
    end
  end
  describe 'soundex' do
    it 'returns the right code' do
      'hello'.soundex.should == 'H400'
    end
  end

  describe 'each_intoken' do
    context 'normal String' do
      before(:each) do
        @str = "picky"
      end
      context 'no params' do
        it "yields the right elements" do
          result = []
          @str.each_intoken do |subtoken|
            result << subtoken
          end
          result.should == %w[picky pick icky pic ick cky pi ic ck ky p i c k y]
        end
      end
      context 'with min_length == 0' do
        it "yields the right elements" do
          result = []
          @str.each_intoken(0) do |subtoken|
            result << subtoken
          end
          result.should == %w[picky pick icky pic ick cky pi ic ck ky p i c k y]
        end
        context 'max_length == 0' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(0, 0) do |subtoken|
              result << subtoken
            end
            result.should == %w[p i c k y]
          end
        end
        context 'max_length == 1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(0, 1) do |subtoken|
              result << subtoken
            end
            result.should == %w[p i c k y]
          end
        end
        context 'max_length == 2' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(0, 2) do |subtoken|
              result << subtoken
            end
            result.should == %w[pi ic ck ky p i c k y]
          end
        end
        context 'max_length == 10' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(0, 10) do |subtoken|
              result << subtoken
            end
            result.should == %w[picky pick icky pic ick cky pi ic ck ky p i c k y]
          end
        end
        context 'max_length == -1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(0, -1) do |subtoken|
              result << subtoken
            end
            result.should == %w[picky pick icky pic ick cky pi ic ck ky p i c k y]
          end
        end
      end
      context 'with min_length == sym.size' do
        it "yields the right elements" do
          result = []
          @str.each_intoken(@str.size) do |subtoken|
            result << subtoken
          end
          result.should == ['picky']
        end
        context 'max_length == 0' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size, 0) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size, 1) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 2' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size, 2) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 10' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size, 10) do |subtoken|
              result << subtoken
            end
            result.should == ['picky']
          end
        end
        context 'max_length == -1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size, -1) do |subtoken|
              result << subtoken
            end
            result.should == ['picky']
          end
        end
      end
      context 'with min_length > sym.size' do
        it "yields the right elements" do
          result = []
          @str.each_intoken(@str.size+1) do |subtoken|
            result << subtoken
          end
          result.should == []
        end
        context 'max_length == 0' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size+1, 0) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size+1, 1) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 2' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size+1, 2) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 10' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size+1, 10) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == -1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(@str.size+1, -1) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
      end
      context 'with min_length < 0' do
        it "yields the right elements" do
          result = []
          @str.each_intoken(-2) do |subtoken|
            result << subtoken
          end
          result.should == %w[picky pick icky]
        end
        context 'max_length == 0' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(-2, 0) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(-2, 1) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 2' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(-2, 2) do |subtoken|
              result << subtoken
            end
            result.should == []
          end
        end
        context 'max_length == 10' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(-2, 10) do |subtoken|
              result << subtoken
            end
            result.should == %w[picky pick icky]
          end
        end
        context 'max_length == -1' do
          it 'yields the right elements' do
            result = []
            @str.each_intoken(-2, -1) do |subtoken|
              result << subtoken
            end
            result.should == %w[picky pick icky]
          end
        end
      end
    end
  end

  describe "each_subtoken" do
    context 'normal String' do
      before(:each) do
        @str = 'reinke'
      end
      context 'no downto' do
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken do |subtoken|
            result << subtoken
          end
          result.should == %w[reinke reink rein rei re r]
        end
      end
      context 'downto is larger than the String' do
        before(:each) do
          @downto = 8
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['reinke']
        end
      end
      context 'downto is exactly the same as String' do
        before(:each) do
          @downto = 6
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['reinke']
        end
      end
      context 'downto is smaller than the length of the String' do
        before(:each) do
          @downto = 4
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == %w[reinke reink rein]
        end
      end
      context 'downto is 1' do
        before(:each) do
          @downto = 1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == %w[reinke reink rein rei re r]
        end
      end
      context 'downto is 0' do
        before(:each) do
          @downto = 0
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == %w[reinke reink rein rei re r]
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -2
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == %w[reinke reink]
        end
      end
    end
    context 'japanese String' do
      before(:each) do
        @str = :日本語
      end
      it "should return an array of japanese Strings, each 1 smaller than the other" do
        result = []
        @str.each_subtoken do |subtoken|
          result << subtoken
        end
        result.should == [:日本語, :日本, :日]
      end
    end
    context 'very short String' do
      before(:each) do
        @str = 'r'
      end
      context 'no downto' do
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is larger than the String' do
        before(:each) do
          @downto = 8
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is exactly the same as String' do
        before(:each) do
          @downto = 6
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is smaller than the length of the String' do
        before(:each) do
          @downto = 4
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is 1' do
        before(:each) do
          @downto = 1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is 0' do
        before(:each) do
          @downto = 0
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -1
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -2
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -3
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
      context 'downto is less than zero' do
        before(:each) do
          @downto = -100
        end
        it "should return an array of pieces of the original token, each 1 smaller than the other" do
          result = []
          @str.each_subtoken(@downto) do |subtoken|
            result << subtoken
          end
          result.should == ['r']
        end
      end
    end
    context "with range param" do
      it "returns a subtoken array from a clipped original" do
        result = []
        'reinke'.each_subtoken 2, (0..3) do |subtoken|
          result << subtoken
        end
        result.should == %w[rein rei re]
      end
      it "returns a subtoken array from a clipped original" do
        result = []
        'reinke'.each_subtoken 2, (1..-2) do |subtoken|
          result << subtoken
        end
        result.should == %w[eink ein ei]
      end
    end
  end

end