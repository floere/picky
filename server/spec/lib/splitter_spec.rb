require 'spec_helper'

describe Picky::Splitter do
  
  let(:splitter) { described_class.new }
  
  describe "single" do
    it "splits right" do
      splitter.single(':b', /:/).should == ['','b']
    end
    it "splits right" do
      splitter.single('a:b', /:/).should == ['a','b']
    end
    it "splits right" do
      splitter.single('a', /:/).should == [nil, 'a']
    end
    it "splits right" do
      splitter.single('a:b c:d', /:/).should == ['a', 'b c:d']
    end
    it "returns the same string if not split" do
      s = 'a'
      splitter.single(s, /:/)[1].object_id.should == s.object_id
    end
  end
  
  describe "multi" do
    it "splits right" do
      splitter.multi(' b', /\s/).should == ['', 'b']
    end
    it "splits right" do
      splitter.multi('a b', /\s/).should == ['a', 'b']
    end
    it "splits right" do
      splitter.multi('a b c d', /\s/).should == ['a', 'b', 'c', 'd']
    end
    it "splits right" do
      splitter.multi('a', /\s/).should == ['a']
    end
    it "returns the same string if not split" do
      s = 'a'
      splitter.multi(s, /\s/).first.object_id.should == s.object_id
    end
  end

end
