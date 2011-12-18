# encoding: utf-8
#
require 'spec_helper'

describe Picky::Generators::Similarity::Metaphone do

  before(:each) do
    @similarity = described_class.new
  end

  def self.it_should_encode text, expected
    it "should encode #{text.inspect} correctly" do
      @similarity.encode(text).should == expected
    end
  end
  # def self.it_should_generate_from index, expected
  #   it "should generate #{expected.inspect} correctly from #{index.inspect}" do
  #     @similarity.generate_from(index).should == expected
  #   end
  # end

  it_should_encode :meier,       :MR
  it_should_encode :grossberger, :KRSBRJR
  it_should_encode :hadelbla,    :HTLBL

  # it_should_generate_from({}, {})
  # it_should_generate_from({ :maier => nil, :meier => nil }, :MR => [:maier, :meier]) # should be correctly ordered
  # it_should_generate_from({ :maier => nil, :meier => nil, :hallaballa => nil }, :MR => [:maier, :meier], :HLBL => [:hallaballa])
  # it_should_generate_from({ :susan => nil, :susanne => nil, :bruderer => nil }, :SSN => [:susan, :susanne], :BRTRR => [:bruderer])

  # describe 'with reduced amount' do
  #   before(:each) do
  #     @similarity = described_class.new(1)
  #   end
  #   it_should_generate_from({ :maier => nil, :meier => nil }, :MR => [:maier])
  #   it_should_generate_from({ :susan => nil, :susanne => nil, :bruderer => nil }, :SSN => [:susan], :BRTRR => [:bruderer])
  # end
  #
  # describe 'hashify' do
  #   it 'should turn an empty list into an empty hash' do
  #     @similarity.send(:hashify, []).should == {}
  #   end
  #   it 'should turn the list into an unordered similarity' do
  #     @similarity.send(:hashify, [:meier, :maier]).should == { :MR => [:meier, :maier] }
  #   end
  #   it 'should turn the list into a encoded hash' do
  #     @similarity.send(:hashify, [:meier, :maier, :peter]).should == { :MR => [:meier, :maier], :PTR => [:peter] }
  #   end
  # end
  #
  # context 'integration' do
  #   it 'should return the right ordered array' do
  #     index = @similarity.generate_from :meier => nil, :maier => nil, :mairai => nil, :mair => nil, :meira => nil
  #     code  = @similarity.encoded :maier
  #
  #     index[code].should == [:mair, :maier, :meier, :meira, :mairai]
  #   end
  # end

end