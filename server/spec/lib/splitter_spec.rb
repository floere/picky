require 'spec_helper'

describe Picky::Splitter do
  
  describe "single" do
    let(:splitter) { described_class.new /:/ }
    it "splits right" do
      splitter.single(':b').should == ['','b']
    end
    it "splits right" do
      splitter.single('a:b').should == ['a','b']
    end
    it "splits right" do
      splitter.single('a').should == [nil, 'a']
    end
    it "splits right" do
      splitter.single('a:b c:d').should == ['a', 'b c:d']
    end
    it "returns the same string if not split" do
      s = 'a'
      splitter.single(s)[1].object_id.should == s.object_id
    end
  end
  
  describe "multi" do
    let(:splitter) { described_class.new /\s/ }
    it "splits right" do
      splitter.multi(' b').should == ['', 'b']
    end
    it "splits right" do
      splitter.multi('a b').should == ['a', 'b']
    end
    it "splits right" do
      splitter.multi('a b c d').should == ['a', 'b', 'c', 'd']
    end
    it "splits right" do
      splitter.multi('a').should == ['a']
    end
    it "returns the same string if not split" do
      s = 'a'
      splitter.multi(s).first.object_id.should == s.object_id
    end
    # it 'is faster than split' do
    #   pattern = /\s/
    #   amount = 1000
    #   text = 'abcd'
    #   split = performance_of do
    #     amount.times { text.split pattern }
    #   end
    #   multi = performance_of do
    #     amount.times { splitter.multi text, pattern }
    #   end
    #   split.should < multi
    # end
    # it 'is slower than split (but uses less memory in the non-split case)' do
    #   pattern = /\s/
    #   amount = 1000
    #   text = 'a b'
    #   multi = performance_of do
    #     amount.times { splitter.multi text, pattern }
    #   end
    #   split = performance_of do
    #     amount.times { text.split pattern }
    #   end
    #   # p split
    #   # p multi
    # end
    # it 'is slower than split (but uses less memory in the non-split case)' do
    #   pattern = /\s/
    #   amount = 1000
    #   text = 'a b c d'
    #   multi = performance_of do
    #     amount.times { splitter.multi text, pattern }
    #   end
    #   split = performance_of do
    #     amount.times { text.split pattern }
    #   end
    #   # p split
    #   # p multi
    # end
  end

end
