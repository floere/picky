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
  
  describe 'puts_gem_missing' do
    it 'should puts right' do
      @object.should_receive(:puts).once.with "gnorf gem missing!\nTo use gnarble gnarf, you need to:\n  1. Add the following line to Gemfile:\n     gem 'gnorf'\n  2. Then, run:\n     bundle update\n"
      
      @object.puts_gem_missing 'gnorf', 'gnarble gnarf'
    end
  end
  
end