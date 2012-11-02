require 'spec_helper'

describe Picky::QualifierMapper do
  
  let(:categories) do
    index      = Picky::Index.new :test
    categories = Picky::Categories.new
    @category1 = categories << Picky::Category.new(:category1, index, :qualifiers => ['t1', 'tt1', 'ttt1'])
    @category2 = categories << Picky::Category.new(:category2, index, :qualifiers => [:t2, :tt2, :ttt2])
    @category3 = categories << Picky::Category.new(:category3, index, :qualifiers => [:t3, :tt3, :ttt3])
    categories
  end
  let(:mapper) { described_class.new categories }
  
  def self.it_should_map(qualifier, expected)
    it "should map #{qualifier} to #{expected}" do
      mapper.map(qualifier).should == expected
    end
  end

  describe "mapping" do
    it { mapper.map(:t1).should   == @category1 }
    it { mapper.map(:tt1).should  == @category1 }
    it { mapper.map(:ttt1).should == @category1 }
    
    it { mapper.map(:t2).should   == @category2 }
    it { mapper.map(:tt2).should  == @category2 }
    it { mapper.map(:ttt2).should == @category2 }
    
    it { mapper.map(:t3).should   == @category3 }
    it { mapper.map(:tt3).should  == @category3 }
    it { mapper.map(:ttt3).should == @category3 }
  end
end