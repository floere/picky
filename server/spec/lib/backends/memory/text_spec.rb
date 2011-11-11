require 'spec_helper'

describe Picky::Backends::Memory::Text do

  let(:text) { described_class.new "some_cache_path" }

  describe 'extension' do
    it 'is correct' do
      text.extension.should == :txt
    end
  end

  describe 'initial' do
    it 'raises' do
      expect {
        text.initial
      }.to raise_error("Can't have an initial content from text file. Use JSON or Marshal.")
    end
  end

  describe "load" do
    it "raises" do
      lambda do
        text.load
      end.should raise_error("Can't load from text file. Use JSON or Marshal.")
    end
  end
  describe "dump" do
    it "raises" do
      lambda do
        text.dump :anything
      end.should raise_error("Can't dump to text file. Use JSON or Marshal.")
    end
  end
  describe "retrieve" do
    before(:each) do
      @io = stub :io
      @io.should_receive(:each_line).once.with.and_yield '123456,some_nice_token'
      ::File.should_receive(:open).any_number_of_times.and_yield @io
    end
    it "yields split lines and returns the id and token text" do
      text.retrieve do |id, token|
        id.should    == '123456'
        token.should == 'some_nice_token'
      end
    end
    it "is fast" do
      performance_of { text.retrieve { |id, token| } }.should < 0.00005
    end
  end

end