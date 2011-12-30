require 'spec_helper'

describe Picky::Query::QualifierCategoryMapper do
  
  let(:index) do
    categories = Picky::Index.new :categories
    @category1 = categories.category :category1, :qualifiers => ['t1', 'tt1', 'ttt1']
    @category2 = categories.category :category2, :qualifiers => [:t2, :tt2, :ttt2]
    @category3 = categories.category :category3, :qualifiers => [:t3, :tt3, :ttt3]
    categories
  end
  let(:indexes) { [index] }
  let(:mapper) { described_class.new indexes }
  
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