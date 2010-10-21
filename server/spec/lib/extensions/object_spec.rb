require 'spec_helper'

describe Object do
  
  before(:each) do
    @object = Object.new
  end
  
  describe "exclaim" do
    it "delegates to puts" do
      @object.should_receive(:puts).once.with :bla
      
      @object.exclaim :bla
    end
  end
  
  describe "timed_exclaim" do
    it "should exclaim right" do
      Time.stub! :now => Time.parse('07-03-1977 12:34:56')
      @object.should_receive(:exclaim).once.with "12:34:56: bla"
      
      @object.timed_exclaim 'bla'
    end
  end
  
end