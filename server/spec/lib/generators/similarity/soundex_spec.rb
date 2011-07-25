# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Similarity::Soundex do

  before(:each) do
    @similarity = described_class.new
  end

  def self.it_should_encode text, expected
    it "should encode #{text.inspect} correctly" do
      @similarity.encoded(text).should == expected
    end
  end
  def self.it_should_generate_from index, expected
    it "should generate #{expected.inspect} correctly from #{index.inspect}" do
      @similarity.generate_from(index).should == expected
    end
  end

  it_should_encode :meier,       :M600
  it_should_encode :grossberger, :G621
  it_should_encode :hadelbla,    :H341

  it_should_generate_from({}, {})
  it_should_generate_from({ :maier => nil, :meier => nil }, :M600 => [:maier, :meier]) # should be correctly ordered
  it_should_generate_from({ :maier => nil, :meier => nil, :hallaballa => nil }, :M600 => [:maier, :meier], :H414 => [:hallaballa])
  it_should_generate_from({ :susan => nil, :susanne => nil, :bruderer => nil }, :S250 => [:susan, :susanne], :B636 => [:bruderer])

  describe 'with reduced amount' do
    before(:each) do
      @similarity = described_class.new(1)
    end
    it_should_generate_from({ :maier => nil, :meier => nil }, :M600 => [:maier])
    it_should_generate_from({ :susan => nil, :susanne => nil, :bruderer => nil }, :S250 => [:susan], :B636 => [:bruderer])
  end

  describe 'hashify' do
    it 'should turn an empty list into an empty hash' do
      @similarity.send(:hashify, []).should == {}
    end
    it 'should turn the list into an unordered similarity' do
      @similarity.send(:hashify, [:meier, :maier]).should == { :M600 => [:meier, :maier] }
    end
    it 'should turn the list into a encoded hash' do
      @similarity.send(:hashify, [:meier, :maier, :peter]).should == { :M600 => [:meier, :maier], :P360 => [:peter] }
    end
  end

  context 'integration' do
    it 'should return the right ordered array' do
      index = @similarity.generate_from :meier => nil, :maier => nil, :mairai => nil, :mair => nil, :meira => nil
      code  = @similarity.encoded :maier

      index[code].should == [:mair, :maier, :meier, :meira, :mairai]
    end
  end

end